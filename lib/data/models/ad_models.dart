/// Whether a listing is live, still a draft, or taken off sale by its seller.
///
/// Only ever anything but [active] on `GET /marketplace/my-ads` — every public
/// read filters to active listings.
enum AdStatus {
  draft,
  active,
  paused;

  static AdStatus fromJson(String? value) => switch (value) {
        'DRAFT' => AdStatus.draft,
        'PAUSED' => AdStatus.paused,
        _ => AdStatus.active,
      };

  String get wireValue => switch (this) {
        AdStatus.draft => 'DRAFT',
        AdStatus.active => 'ACTIVE',
        AdStatus.paused => 'PAUSED',
      };
}

/// A seller's marketplace listing (`/marketplace/*`).
///
/// "Best sellers" is these ads ranked by engagement — wishlists first, views
/// breaking ties — so [wishlistCount] and [viewCount] are shown on the card
/// alongside [ratingAverage], which counts only listings people have rated.
class AdModel {
  const AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sellerName,
    required this.categorySlug,
    required this.icon,
    required this.price,
    required this.priceUnit,
    required this.location,
    this.lat,
    this.lng,
    required this.viewCount,
    required this.wishlistCount,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    required this.isWishlisted,
    this.imageUrls = const [],
    this.status = AdStatus.active,
    this.attributes = const {},
  });

  final String id;
  final String title;
  final String description;

  /// The seller's business name, or their own name if they have no profile.
  final String sellerName;
  final String categorySlug;

  /// Emoji shown until the seller uploads a photo.
  final String icon;
  final double price;

  /// "/ visit", "/ day", "starting" — display only.
  final String priceUnit;

  /// "Koramangala, Bengaluru", or empty if the seller gave no location.
  final String location;

  /// Centre of [location]. Null when we have no coordinate for it, in which
  /// case the coverage map is hidden.
  final double? lat;
  final double? lng;

  final int viewCount;
  final int wishlistCount;

  /// Average of the reviews on this listing's completed orders. Meaningless
  /// on its own — check [isRated] first, since an unrated listing is 0, not
  /// bad.
  final double ratingAverage;
  final int ratingCount;
  final bool isWishlisted;

  /// Whether anyone has actually rated this listing. A card shows "New"
  /// rather than 0★ when they have not.
  bool get isRated => ratingCount > 0;

  /// Presigned URLs. Empty until the seller uploads a photo.
  final List<String> imageUrls;

  /// Meaningful only among the seller's own listings.
  final AdStatus status;

  /// Category-specific detail the vertical screens render — `seats` and
  /// `transmission` on a rental, `roomType` on a stay, `durationLabel` on a
  /// clean. Empty for categories that define none, and for ads whose seller
  /// filled none in, so readers can index it without a null check.
  final Map<String, dynamic> attributes;

  /// A typed read of one attribute, or null when it is absent or the wrong
  /// shape. The backend validates these on write, but an older ad may simply
  /// not carry the key.
  T? attribute<T>(String key) {
    final value = attributes[key];
    return value is T ? value : null;
  }

  /// "₹180 / visit"
  String get priceLabel =>
      '₹${price.toStringAsFixed(0)}${priceUnit.isEmpty ? '' : ' $priceUnit'}';

  AdModel copyWith({bool? isWishlisted, int? wishlistCount, AdStatus? status}) =>
      AdModel(
        id: id,
        title: title,
        description: description,
        sellerName: sellerName,
        categorySlug: categorySlug,
        icon: icon,
        price: price,
        priceUnit: priceUnit,
        location: location,
        lat: lat,
        lng: lng,
        viewCount: viewCount,
        wishlistCount: wishlistCount ?? this.wishlistCount,
        ratingAverage: ratingAverage,
        ratingCount: ratingCount,
        isWishlisted: isWishlisted ?? this.isWishlisted,
        imageUrls: imageUrls,
        status: status ?? this.status,
        attributes: attributes,
      );

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        sellerName: (json['sellerName'] as String?) ?? '',
        categorySlug: (json['categorySlug'] as String?) ?? '',
        icon: (json['icon'] as String?) ?? '🛍️',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        priceUnit: (json['priceUnit'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        viewCount: (json['viewCount'] as int?) ?? 0,
        wishlistCount: (json['wishlistCount'] as int?) ?? 0,
        ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0,
        ratingCount: (json['ratingCount'] as int?) ?? 0,
        status: AdStatus.fromJson(json['status'] as String?),
        isWishlisted: (json['isWishlisted'] as bool?) ?? false,
        imageUrls: ((json['imageUrls'] as List?) ?? const []).cast<String>(),
        // Null on categories that take no extras, and on every ad posted
        // before attributes existed.
        attributes: (json['attributes'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}

/// Lifecycle of an order placed against a listing.
enum AdOrderStatus {
  newOrder,
  inProgress,
  completed,
  cancelled;

  static AdOrderStatus fromJson(String? value) => switch (value) {
        'IN_PROGRESS' => AdOrderStatus.inProgress,
        'COMPLETED' => AdOrderStatus.completed,
        'CANCELLED' => AdOrderStatus.cancelled,
        _ => AdOrderStatus.newOrder,
      };

  String get wireValue => switch (this) {
        AdOrderStatus.newOrder => 'NEW',
        AdOrderStatus.inProgress => 'IN_PROGRESS',
        AdOrderStatus.completed => 'COMPLETED',
        AdOrderStatus.cancelled => 'CANCELLED',
      };
}

/// One row in the seller's Orders tab, or in the buyer's own order list.
class AdOrderModel {
  const AdOrderModel({
    required this.id,
    required this.code,
    required this.adId,
    required this.status,
    required this.amount,
    required this.serviceName,
    required this.icon,
    required this.customerName,
    required this.customerPhone,
    required this.addressText,
    required this.whenLabel,
    this.note,
  });

  final String id;

  /// Reference both sides quote, e.g. `ELK-A-4T29K`.
  final String code;
  final String adId;
  final AdOrderStatus status;

  /// The listing's price when it was ordered — the seller may reprice later.
  final double amount;
  final String serviceName;
  final String icon;
  final String customerName;
  final String customerPhone;
  final String addressText;

  /// "12 Jun 2026", or "As soon as possible" when the buyer picked no time.
  final String whenLabel;
  final String? note;

  String get amountLabel => '₹${amount.toStringAsFixed(0)}';

  AdOrderModel copyWith({AdOrderStatus? status}) => AdOrderModel(
        id: id,
        code: code,
        adId: adId,
        status: status ?? this.status,
        amount: amount,
        serviceName: serviceName,
        icon: icon,
        customerName: customerName,
        customerPhone: customerPhone,
        addressText: addressText,
        whenLabel: whenLabel,
        note: note,
      );

  factory AdOrderModel.fromJson(Map<String, dynamic> json) => AdOrderModel(
        id: json['id'] as String,
        code: (json['code'] as String?) ?? '',
        adId: (json['adId'] as String?) ?? '',
        status: AdOrderStatus.fromJson(json['status'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        serviceName: (json['serviceName'] as String?) ?? '',
        icon: (json['icon'] as String?) ?? '🛍️',
        customerName: (json['customerName'] as String?) ?? '',
        customerPhone: (json['customerPhone'] as String?) ?? '',
        addressText: (json['addressText'] as String?) ?? '',
        whenLabel: (json['whenLabel'] as String?) ?? '',
        note: json['note'] as String?,
      );
}
