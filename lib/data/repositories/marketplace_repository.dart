import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/ad_models.dart';

/// Seller ads and the engagement ranking behind "Best sellers".
///
/// Backend contract:
///  * `GET    /marketplace/top-sellers?limit=&category=` → ranked ads
///  * `GET    /marketplace/ads?q=&category=&limit=`      → browse / search
///  * `GET    /marketplace/ads/:id`                      → detail (records a view)
///  * `POST   /marketplace/ads/:id/wishlist`             → save
///  * `DELETE /marketplace/ads/:id/wishlist`             → unsave
///  * `GET    /marketplace/my-ads?status=`               → the caller's own listings
///  * `POST   /marketplace/ads`                          → create (draft or live)
///  * `PATCH  /marketplace/ads/:id`                      → edit, pause, resume
///  * `DELETE /marketplace/ads/:id`                      → soft delete
///  * `POST   /marketplace/ads/:id/orders`             → place an order
///  * `GET    /marketplace/seller-orders?status=`       → orders received
///  * `GET    /marketplace/seller-orders/counts`        → per-status tallies
///  * `GET    /marketplace/orders?status=`              → orders placed
///  * `PATCH  /marketplace/orders/:id/status`           → advance or cancel
class MarketplaceRepository {
  MarketplaceRepository(this._client);

  final ApiClient _client;

  Future<List<AdModel>> topSellers({int? limit, String? category}) async {
    final data = await _client.get(ApiEndpoints.marketplaceTopSellers, queryParameters: {
      'limit': ?limit,
      'category': ?category,
    }) as List;
    return data.map((e) => AdModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AdModel>> listAds({String? query, String? category, int? limit}) async {
    final data = await _client.get(ApiEndpoints.marketplaceAds, queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      'category': ?category,
      'limit': ?limit,
    }) as List;
    return data.map((e) => AdModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Opens an ad. The backend records the view, de-duplicated per user, so
  /// this is the call that feeds the ranking.
  Future<AdModel> getAd(String id) async {
    final data = await _client.get(ApiEndpoints.marketplaceAd(id));
    return AdModel.fromJson(data as Map<String, dynamic>);
  }

  /// Saves or unsaves an ad, returning the server's new count for it.
  Future<({bool isWishlisted, int wishlistCount})> setWishlisted(
    String id, {
    required bool wishlisted,
  }) async {
    final path = ApiEndpoints.marketplaceAdWishlist(id);
    final data = (wishlisted
        ? await _client.post(path)
        : await _client.delete(path)) as Map<String, dynamic>;
    return (
      isWishlisted: data['isWishlisted'] as bool,
      wishlistCount: data['wishlistCount'] as int,
    );
  }

  // ─── seller-owned listings ────────────────────────────────────────────────

  /// The signed-in seller's own ads. Unlike every other read here this
  /// includes drafts and paused listings — that is the point of My Listings.
  Future<List<AdModel>> myAds({AdStatus? status}) async {
    final data = await _client.get(
      ApiEndpoints.marketplaceMyAds,
      queryParameters: {'status': ?status?.wireValue},
    ) as List;
    return data.map((e) => AdModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdModel> createAd({
    required String title,
    required String categorySlug,
    required double price,
    String? description,
    String? priceUnit,
    String? locality,
    String? city,
    String? icon,
    AdStatus status = AdStatus.active,
    List<String> imageKeys = const [],
    Map<String, dynamic> attributes = const {},
  }) async {
    final data = await _client.post(ApiEndpoints.marketplaceAds, data: {
      'title': title,
      'categorySlug': categorySlug,
      'price': price,
      'description': ?description,
      'priceUnit': ?priceUnit,
      'icon': ?icon,
      'locality': ?locality,
      'city': ?city,
      'status': status.wireValue,
      if (imageKeys.isNotEmpty) 'imageKeys': imageKeys,
      // Omitted rather than sent empty: the backend rejects attributes on
      // categories that define none, and {} would be a pointless round trip.
      if (attributes.isNotEmpty) 'attributes': attributes,
    });
    return AdModel.fromJson(data as Map<String, dynamic>);
  }

  /// Partial update — send only what changed. Omitting [imageKeys] leaves the
  /// listing's photos alone; passing an empty list removes them all.
  Future<AdModel> updateAd(
    String id, {
    String? title,
    String? categorySlug,
    double? price,
    String? description,
    String? priceUnit,
    String? locality,
    String? city,
    String? icon,
    AdStatus? status,
    List<String>? imageKeys,
    Map<String, dynamic>? attributes,
  }) async {
    final data = await _client.patch(ApiEndpoints.marketplaceAd(id), data: {
      'title': ?title,
      'categorySlug': ?categorySlug,
      'price': ?price,
      'description': ?description,
      'priceUnit': ?priceUnit,
      'icon': ?icon,
      'locality': ?locality,
      'city': ?city,
      'status': ?status?.wireValue,
      // Null drops the key entirely (keep the photos); an empty list is sent
      // as-is and clears them.
      'imageKeys': ?imageKeys,
      // Same rule: null leaves the stored details alone, {} clears them.
      'attributes': ?attributes,
    });
    return AdModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteAd(String id) async {
    await _client.delete(ApiEndpoints.marketplaceAd(id));
  }

  /// Uploads a photo and returns its storage key, to be sent as part of
  /// `imageKeys` when the listing is saved. The backend downscales and
  /// re-encodes, so the original does not need resizing here.
  Future<String> uploadImage(String filePath, {String purpose = 'ads'}) async {
    final data = await _client.postMultipart(
      ApiEndpoints.uploadImage,
      FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'purpose': purpose,
      }),
    );
    return (data as Map<String, dynamic>)['key'] as String;
  }

  // ─── orders ───────────────────────────────────────────────────────────────

  /// Places an order against [adId]. Fails with 404 on a paused or draft
  /// listing, and 409 if the caller owns it.
  Future<AdOrderModel> placeOrder(
    String adId, {
    required String addressText,
    required String contactPhone,
    int quantity = 1,
    bool isEnquiry = false,
    DateTime? scheduledAt,
    DateTime? endAt,
    int? durationMonths,
    double? depositAmount,
    double? feesAmount,
    double? taxAmount,
    String? note,
  }) async {
    final data = await _client.post(
      ApiEndpoints.marketplaceAdOrders(adId),
      data: {
        'addressText': addressText,
        'contactPhone': contactPhone,
        // Sent only when it is not the default, so the common case stays the
        // payload it has always been.
        if (quantity != 1) 'quantity': quantity,
        // A viewing or a quote request costs nothing; the backend places it
        // at zero rather than charging the listing price.
        if (isEnquiry) 'isEnquiry': true,
        'scheduledAt': ?scheduledAt?.toUtc().toIso8601String(),
        // A booked period: a rental's return, a stay's move-out.
        'endAt': ?endAt?.toUtc().toIso8601String(),
        'durationMonths': ?durationMonths,
        'depositAmount': ?depositAmount,
        // What the screen added on top of the listing price, so the order and
        // the receipt the buyer saw agree.
        'feesAmount': ?feesAmount,
        'taxAmount': ?taxAmount,
        'note': ?note,
      },
    );
    return AdOrderModel.fromJson(data as Map<String, dynamic>);
  }

  /// Orders placed against the signed-in seller's listings.
  Future<List<AdOrderModel>> sellerOrders({AdOrderStatus? status}) async {
    final data = await _client.get(
      ApiEndpoints.marketplaceSellerOrders,
      queryParameters: {'status': ?status?.wireValue},
    ) as List;
    return data.map((e) => AdOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Orders the signed-in user has placed as a buyer.
  Future<List<AdOrderModel>> myOrders({AdOrderStatus? status}) async {
    final data = await _client.get(
      ApiEndpoints.marketplaceMyOrders,
      queryParameters: {'status': ?status?.wireValue},
    ) as List;
    return data.map((e) => AdOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdOrderModel> setOrderStatus(String orderId, AdOrderStatus status) async {
    final data = await _client.patch(
      ApiEndpoints.marketplaceOrderStatus(orderId),
      data: {'status': status.wireValue},
    );
    return AdOrderModel.fromJson(data as Map<String, dynamic>);
  }
}
