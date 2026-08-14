import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/repositories/marketplace_repository.dart';

/// Base for the marketplace fakes.
///
/// `MarketplaceRepository` spans three surfaces — buying, selling and orders —
/// and no single test needs all of them. Every method throws by default so a
/// spec overrides only what it exercises, and an unexpected call fails loudly
/// instead of quietly returning an empty list.
class FakeMarketplaceRepositoryBase implements MarketplaceRepository {
  @override
  Future<List<AdModel>> topSellers({int? limit, String? category}) =>
      throw UnimplementedError();

  @override
  Future<List<AdModel>> listAds({String? query, String? category, int? limit}) =>
      throw UnimplementedError();

  @override
  Future<AdModel> getAd(String id) => throw UnimplementedError();

  @override
  Future<({bool isWishlisted, int wishlistCount})> setWishlisted(
    String adId, {
    required bool wishlisted,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<AdModel>> myAds({AdStatus? status}) => throw UnimplementedError();

  @override
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
  }) =>
      throw UnimplementedError();

  @override
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
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAd(String id) => throw UnimplementedError();

  @override
  Future<String> uploadImage(String filePath, {String purpose = 'ads'}) =>
      throw UnimplementedError();

  @override
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
  }) =>
      throw UnimplementedError();

  @override
  Future<List<AdOrderModel>> sellerOrders({AdOrderStatus? status}) =>
      throw UnimplementedError();

  @override
  Future<List<AdOrderModel>> myOrders({AdOrderStatus? status}) =>
      throw UnimplementedError();

  @override
  Future<AdOrderModel> setOrderStatus(String orderId, AdOrderStatus status) =>
      throw UnimplementedError();
}
