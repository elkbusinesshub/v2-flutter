/// Which dispatch product a partner is driving for.
enum DriverService {
  ride,
  porter;

  String get wireValue => switch (this) {
        DriverService.ride => 'RIDE',
        DriverService.porter => 'PORTER',
      };

  static DriverService fromJson(String? value) =>
      value == 'PORTER' ? DriverService.porter : DriverService.ride;
}

/// One vehicle pin on the map — a real partner, on duty, right now.
///
/// The backend returns only partners who are online, free, and whose position
/// is recent, so an empty list genuinely means "nobody is out there" rather
/// than "we have not looked".
class NearbyVehicleModel {
  const NearbyVehicleModel({
    required this.vehicleSlug,
    required this.emoji,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.etaMinutes,
  });

  final String vehicleSlug;

  /// The class's emoji — 🛺 for an auto, 🏍️ for a delivery bike. What the map
  /// draws, so a rider can tell an auto from a car at a glance.
  final String emoji;
  final double lat;
  final double lng;
  final double distanceKm;
  final int etaMinutes;

  factory NearbyVehicleModel.fromJson(Map<String, dynamic> json) =>
      NearbyVehicleModel(
        vehicleSlug: (json['vehicleSlug'] as String?) ?? '',
        emoji: (json['emoji'] as String?) ?? '🚗',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        etaMinutes: (json['etaMinutes'] as int?) ?? 0,
      );
}

/// The vehicle a partner has registered, and whether they are on duty.
class DriverProfileModel {
  const DriverProfileModel({
    required this.id,
    required this.service,
    required this.vehicleSlug,
    required this.vehicleLabel,
    required this.plateNumber,
    required this.isOnline,
    this.lat,
    this.lng,
    this.activeBookingId,
  });

  final String id;
  final DriverService service;
  final String vehicleSlug;
  final String vehicleLabel;
  final String plateNumber;
  final bool isOnline;
  final double? lat;
  final double? lng;

  /// The job in hand, so reopening the app lands back on it.
  final String? activeBookingId;

  bool get isBusy => activeBookingId != null;

  DriverProfileModel copyWith({bool? isOnline}) => DriverProfileModel(
        id: id,
        service: service,
        vehicleSlug: vehicleSlug,
        vehicleLabel: vehicleLabel,
        plateNumber: plateNumber,
        isOnline: isOnline ?? this.isOnline,
        lat: lat,
        lng: lng,
        activeBookingId: activeBookingId,
      );

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) =>
      DriverProfileModel(
        id: json['id'] as String,
        service: DriverService.fromJson(json['service'] as String?),
        vehicleSlug: (json['vehicleSlug'] as String?) ?? '',
        vehicleLabel: (json['vehicleLabel'] as String?) ?? '',
        plateNumber: (json['plateNumber'] as String?) ?? '',
        isOnline: (json['isOnline'] as bool?) ?? false,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        activeBookingId: json['activeBookingId'] as String?,
      );
}

/// A job offered to a partner over the dispatch socket.
///
/// Every partner nearby gets the same offer at once and the first to accept
/// takes it, so this is a chance at the job rather than an assignment.
class JobOfferModel {
  const JobOfferModel({
    required this.bookingId,
    required this.service,
    required this.code,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.distanceKm,
    required this.pickupDistanceKm,
    required this.expiresInSeconds,
  });

  final String bookingId;
  final DriverService service;
  final String code;
  final String pickupAddress;
  final String dropAddress;
  final double fare;

  /// Length of the trip itself.
  final double distanceKm;

  /// How far the partner is from the pickup — the number that decides whether
  /// the job is worth taking.
  final double pickupDistanceKm;
  final int expiresInSeconds;

  factory JobOfferModel.fromJson(Map<String, dynamic> json) => JobOfferModel(
        bookingId: json['bookingId'] as String,
        service: DriverService.fromJson(json['service'] as String?),
        code: (json['code'] as String?) ?? '',
        pickupAddress: (json['pickupAddress'] as String?) ?? '',
        dropAddress: (json['dropAddress'] as String?) ?? '',
        fare: (json['fare'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        pickupDistanceKm: (json['pickupDistanceKm'] as num?)?.toDouble() ?? 0,
        expiresInSeconds: (json['expiresInSeconds'] as int?) ?? 60,
      );
}
