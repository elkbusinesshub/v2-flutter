/// Models for the car-rental vertical (backend `/rentals/*`).
///
/// The backend's car payload carries both the legacy display fields
/// (`type`, `icon`, `isBestDeal`) and the richer listing fields
/// (`category`, `iconKey`, `fuel`, `rating`, `badge`), so both the old
/// cards and the booking flow read from one model.
class RentalCarModel {
  const RentalCarModel({
    required this.id,
    required this.name,
    required this.type,
    required this.transmission,
    required this.seats,
    required this.icon,
    required this.pricePerDay,
    this.isBestDeal = false,
    this.category = '',
    this.iconKey = '',
    this.fuel = '',
    this.rating = 0,
    this.badge,
  });

  final String id;
  final String name;
  final String type;
  final String transmission;
  final int seats;
  final String icon;
  final double pricePerDay;
  final bool isBestDeal;

  /// Wire id used by the filter chips: `sedan | suv | luxury`.
  final String category;

  /// SVG asset basename for the listing card.
  final String iconKey;
  final String fuel;
  final double rating;
  final String? badge;

  String get svgAsset => 'assets/icons/$iconKey.svg';

  factory RentalCarModel.fromJson(Map<String, dynamic> json) => RentalCarModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        transmission: json['transmission'] as String,
        seats: json['seats'] as int,
        icon: json['icon'] as String,
        pricePerDay: (json['pricePerDay'] as num).toDouble(),
        isBestDeal: json['isBestDeal'] as bool? ?? false,
        category: json['category'] as String? ?? '',
        iconKey: json['iconKey'] as String? ?? '',
        fuel: json['fuel'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        badge: json['badge'] as String?,
      );
}

enum RentalPeriod { daily, weekly, monthly }

extension RentalPeriodX on RentalPeriod {
  /// Wire id the backend expects (`rentalType` / `period`).
  String get id => switch (this) {
        RentalPeriod.daily => 'daily',
        RentalPeriod.weekly => 'weekly',
        RentalPeriod.monthly => 'monthly',
      };
}

/// A self-pickup branch (`GET /rentals/branches`).
class RentalBranchModel {
  const RentalBranchModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.address,
    required this.distance,
    this.lat,
    this.lng,
  });

  final String id;
  final String slug;
  final String name;
  final String address;
  final String distance;

  /// Null for a branch whose location has not been recorded; the pickup step
  /// then hides the map rather than centring on somewhere arbitrary.
  final double? lat;
  final double? lng;

  factory RentalBranchModel.fromJson(Map<String, dynamic> json) =>
      RentalBranchModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        distance: json['distance'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

/// An add-on priced per day (`GET /rentals/extras`).
class RentalExtraModel {
  const RentalExtraModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.pricePerDay,
  });

  final String id;

  /// Wire key sent in `extras: [...]`, e.g. `protection`.
  final String key;
  final String name;
  final String description;
  final int pricePerDay;

  factory RentalExtraModel.fromJson(Map<String, dynamic> json) =>
      RentalExtraModel(
        id: json['id'] as String,
        key: json['key'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        pricePerDay: json['pricePerDay'] as int,
      );
}

/// Server-computed price breakdown (quote and booking share this shape).
class RentalBreakdown {
  const RentalBreakdown({
    required this.days,
    required this.dailyRate,
    required this.rentalTotal,
    required this.deliveryFee,
    required this.extrasTotal,
    required this.subtotal,
    required this.promoDiscount,
    required this.vatAmount,
    required this.totalAmount,
    this.promoCode,
    this.lateFee = 0,
  });

  final int days;
  final int dailyRate;
  final int rentalTotal;
  final int deliveryFee;
  final int extrasTotal;
  final int subtotal;
  final String? promoCode;
  final int promoDiscount;
  final int vatAmount;
  final int lateFee;
  final int totalAmount;

  factory RentalBreakdown.fromJson(Map<String, dynamic> json) => RentalBreakdown(
        days: json['days'] as int,
        dailyRate: json['dailyRate'] as int,
        rentalTotal: json['rentalTotal'] as int,
        deliveryFee: json['deliveryFee'] as int,
        extrasTotal: json['extrasTotal'] as int,
        subtotal: json['subtotal'] as int,
        promoCode: json['promoCode'] as String?,
        promoDiscount: json['promoDiscount'] as int,
        vatAmount: json['vatAmount'] as int,
        lateFee: (json['lateFee'] as int?) ?? 0,
        totalAmount: json['totalAmount'] as int,
      );
}

/// `POST /rentals/quote` result — the review step's authoritative pricing.
class RentalQuoteModel {
  const RentalQuoteModel({
    required this.car,
    required this.rentalType,
    required this.breakdown,
  });

  final RentalCarModel car;
  final String rentalType;
  final RentalBreakdown breakdown;

  factory RentalQuoteModel.fromJson(Map<String, dynamic> json) => RentalQuoteModel(
        car: RentalCarModel.fromJson(json['car'] as Map<String, dynamic>),
        rentalType: json['rentalType'] as String,
        breakdown:
            RentalBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
      );
}

/// A created rental booking (success ticket / history).
class RentalBookingModel {
  const RentalBookingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.rentalType,
    required this.car,
    required this.fulfilment,
    required this.pickupAt,
    required this.returnAt,
    required this.breakdown,
    this.branchName,
    this.deliveryAddress,
  });

  final String id;

  /// Booking reference, e.g. `ELK-48213`.
  final String code;
  final String status;
  final String rentalType;
  final RentalCarModel car;
  final String fulfilment;
  final String? branchName;
  final String? deliveryAddress;
  final DateTime pickupAt;
  final DateTime returnAt;
  final RentalBreakdown breakdown;

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>?;
    return RentalBookingModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      rentalType: json['rentalType'] as String,
      car: RentalCarModel.fromJson(json['car'] as Map<String, dynamic>),
      fulfilment: json['fulfilment'] as String,
      branchName: branch?['name'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      pickupAt: DateTime.parse(json['pickupAt'] as String),
      returnAt: DateTime.parse(json['returnAt'] as String),
      breakdown:
          RentalBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
    );
  }
}
