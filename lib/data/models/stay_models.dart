import '../../core/l10n/l10n.dart';

enum StayCategoryType { pgStay, mensHostel, womensHostel, homestay }

extension StayCategoryTypeX on StayCategoryType {
  String get displayName => switch (this) {
        StayCategoryType.pgStay => L10n.current.pgStays,
        StayCategoryType.mensHostel => L10n.current.svcMensHostel,
        StayCategoryType.womensHostel => L10n.current.svcWomensHostel,
        StayCategoryType.homestay => L10n.current.homestays,
      };

  String get id => switch (this) {
        StayCategoryType.pgStay => 'pg_stay',
        StayCategoryType.mensHostel => 'mens_hostel',
        StayCategoryType.womensHostel => 'womens_hostel',
        StayCategoryType.homestay => 'homestay',
      };

  static StayCategoryType fromId(String id) => switch (id) {
        'pg_stay' => StayCategoryType.pgStay,
        'mens_hostel' => StayCategoryType.mensHostel,
        'womens_hostel' => StayCategoryType.womensHostel,
        _ => StayCategoryType.homestay,
      };
}

class StayCategoryModel {
  const StayCategoryModel({
    required this.type,
    required this.name,
    required this.count,
    required this.gradientStart,
    required this.gradientEnd,
    required this.emoji,
  });

  final StayCategoryType type;
  final String name;
  final int count;
  final int gradientStart;
  final int gradientEnd;
  final String emoji;

  factory StayCategoryModel.fromJson(Map<String, dynamic> json) =>
      StayCategoryModel(
        type: StayCategoryTypeX.fromId(json['type'] as String),
        name: json['name'] as String,
        count: json['count'] as int,
        gradientStart: json['gradientStart'] as int,
        gradientEnd: json['gradientEnd'] as int,
        emoji: json['emoji'] as String,
      );
}

class StayAmenity {
  const StayAmenity({required this.iconKey, required this.label});

  final String iconKey;
  final String label;

  factory StayAmenity.fromJson(Map<String, dynamic> json) => StayAmenity(
        iconKey: json['iconKey'] as String,
        label: json['label'] as String,
      );
}

class StayModel {
  const StayModel({
    required this.id,
    required this.name,
    required this.categoryType,
    required this.badge,
    required this.roomType,
    required this.location,
    required this.fullAddress,
    required this.distanceKm,
    required this.pricePerMonth,
    required this.rating,
    required this.isVerified,
    required this.amenities,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;
  final String name;
  final StayCategoryType categoryType;
  final String badge;
  final String roomType;
  final String location;
  final String fullAddress;
  final double distanceKm;
  final int pricePerMonth;
  final double rating;
  final bool isVerified;
  final List<StayAmenity> amenities;
  final String description;
  final int gradientStart;
  final int gradientEnd;

  factory StayModel.fromJson(Map<String, dynamic> json) => StayModel(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryType: StayCategoryTypeX.fromId(json['categoryType'] as String),
        badge: json['badge'] as String,
        roomType: json['roomType'] as String,
        location: json['location'] as String,
        fullAddress: json['fullAddress'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        pricePerMonth: json['pricePerMonth'] as int,
        rating: (json['rating'] as num).toDouble(),
        isVerified: json['isVerified'] as bool? ?? false,
        amenities: (json['amenities'] as List<dynamic>)
            .map((e) => StayAmenity.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: json['description'] as String? ?? '',
        gradientStart: json['gradientStart'] as int,
        gradientEnd: json['gradientEnd'] as int,
      );
}

/// A bookable room option on a stay (backend `roomOptions` on stay detail).
class StayRoomOption {
  const StayRoomOption({
    required this.id,
    required this.kind,
    required this.subtitle,
    required this.pricePerMonth,
  });

  final String id;
  final String kind;
  final String subtitle;
  final int pricePerMonth;

  factory StayRoomOption.fromJson(Map<String, dynamic> json) => StayRoomOption(
        id: json['id'] as String,
        kind: json['kind'] as String,
        subtitle: json['subtitle'] as String,
        pricePerMonth: json['pricePerMonth'] as int,
      );
}

/// Stay detail — the listing plus the viewer's saved flag and room options.
class StayDetailModel {
  const StayDetailModel({
    required this.stay,
    required this.isSaved,
    required this.roomOptions,
  });

  final StayModel stay;
  final bool isSaved;
  final List<StayRoomOption> roomOptions;

  factory StayDetailModel.fromJson(Map<String, dynamic> json) => StayDetailModel(
        stay: StayModel.fromJson(json),
        isSaved: json['isSaved'] as bool? ?? false,
        roomOptions: (json['roomOptions'] as List? ?? const [])
            .map((e) => StayRoomOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum StayBookingStatus { confirmed, visitBooked, pending, past }

extension StayBookingStatusX on StayBookingStatus {
  String get label => switch (this) {
        StayBookingStatus.confirmed => L10n.current.statusConfirmed,
        StayBookingStatus.visitBooked => L10n.current.statusVisitBooked,
        StayBookingStatus.pending => L10n.current.statusPending,
        StayBookingStatus.past => L10n.current.statusCompleted,
      };
}

class StayBookingModel {
  const StayBookingModel({
    required this.id,
    this.code = '',
    required this.stayName,
    required this.badge,
    required this.roomType,
    required this.location,
    required this.status,
    required this.primaryDateLabel,
    required this.primaryDate,
    required this.rentPerMonth,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;

  /// Booking reference shown on confirmation, e.g. `ELK-7QK2M`.
  final String code;
  final String stayName;
  final String badge;
  final String roomType;
  final String location;
  final StayBookingStatus status;
  final String primaryDateLabel;
  final String primaryDate;
  final int rentPerMonth;
  final String secondaryLabel;
  final String secondaryValue;
  final int gradientStart;
  final int gradientEnd;

  factory StayBookingModel.fromJson(Map<String, dynamic> json) =>
      StayBookingModel(
        id: json['id'] as String,
        code: json['code'] as String? ?? '',
        stayName: json['stayName'] as String,
        badge: json['badge'] as String,
        roomType: json['roomType'] as String,
        location: json['location'] as String,
        status: switch (json['status'] as String) {
          'visit_booked' => StayBookingStatus.visitBooked,
          'pending' => StayBookingStatus.pending,
          'past' => StayBookingStatus.past,
          _ => StayBookingStatus.confirmed,
        },
        primaryDateLabel: json['primaryDateLabel'] as String,
        primaryDate: json['primaryDate'] as String,
        rentPerMonth: json['rentPerMonth'] as int,
        secondaryLabel: json['secondaryLabel'] as String,
        secondaryValue: json['secondaryValue'] as String,
        gradientStart: json['gradientStart'] as int,
        gradientEnd: json['gradientEnd'] as int,
      );
}

class ElkStayHomeFeed {
  const ElkStayHomeFeed({
    required this.userName,
    required this.location,
    required this.categories,
    required this.topRated,
  });

  final String userName;
  final String location;
  final List<StayCategoryModel> categories;
  final List<StayModel> topRated;
}
