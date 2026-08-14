/// A ride-type option (Auto, Economy, Comfort, ELK XL).
///
/// The backend emits the legacy display fields (`id`, `emoji`, `name`,
/// `price`) plus the richer card fields, so one model serves both the taxi
/// screen and the booking flow.
class RideTypeModel {
  const RideTypeModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    this.iconKey = '',
    this.seats = 0,
    this.etaMinutes = 0,
    this.cancellationFee = 0,
    this.badge,
  });

  /// Wire slug, e.g. `auto` — sent as `rideTypeId`.
  final String id;
  final String emoji;
  final String name;

  /// Base fare in rupees.
  final double price;
  final String iconKey;
  final int seats;
  final int etaMinutes;
  final double cancellationFee;
  final String? badge;

  factory RideTypeModel.fromJson(Map<String, dynamic> json) => RideTypeModel(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        iconKey: json['iconKey'] as String? ?? '',
        seats: (json['seats'] as int?) ?? 0,
        etaMinutes: (json['etaMinutes'] as int?) ?? 0,
        cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0,
        badge: json['badge'] as String?,
      );
}

/// Pickup / drop-off estimate for the map header.
class TaxiLocationModel {
  const TaxiLocationModel({
    required this.pickup,
    required this.drop,
    required this.etaMinutes,
    required this.distanceKm,
  });

  final String pickup;
  final String drop;
  final int etaMinutes;
  final double distanceKm;

  factory TaxiLocationModel.fromJson(Map<String, dynamic> json) =>
      TaxiLocationModel(
        pickup: json['pickup'] as String,
        drop: json['drop'] as String,
        etaMinutes: json['etaMinutes'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );
}

/// Driver-match preview (`POST /rides/request`) — no booking is created.
class DriverMatchModel {
  const DriverMatchModel({
    required this.driverName,
    required this.vehicle,
    required this.plateNumber,
    required this.etaMinutes,
  });

  final String driverName;
  final String vehicle;
  final String plateNumber;
  final int etaMinutes;

  factory DriverMatchModel.fromJson(Map<String, dynamic> json) =>
      DriverMatchModel(
        driverName: json['driverName'] as String,
        vehicle: json['vehicle'] as String,
        plateNumber: json['plateNumber'] as String,
        etaMinutes: json['etaMinutes'] as int,
      );
}

/// A ride booking through its lifecycle: assigned → started → completed.
class RideBookingModel {
  const RideBookingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.rideType,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.driverName,
    required this.vehicle,
    required this.plateNumber,
    required this.fare,
    required this.paymentMethod,
    this.otpCode,
    this.cancellationFee = 0,
    this.tipAmount = 0,
    this.ratingStars,
    this.startedAt,
    this.completedAt,
  });

  final String id;

  /// Tracking code shown on the receipt, e.g. `ELK-7QK2M9P`.
  final String code;

  /// `assigned | started | completed | cancelled`
  final String status;
  final RideTypeModel rideType;
  final String pickupAddress;
  final String dropAddress;
  final double distanceKm;
  final int etaMinutes;
  final String driverName;
  final String vehicle;
  final String plateNumber;

  /// Pickup OTP the rider hands to the driver — null once the trip starts.
  final String? otpCode;
  final double fare;
  final double cancellationFee;
  final double tipAmount;
  final int? ratingStars;
  final String paymentMethod;
  final DateTime? startedAt;
  final DateTime? completedAt;

  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;

  /// Total charged including any tip added at rating time.
  double get totalPaid => fare + tipAmount;

  factory RideBookingModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>;
    final breakdown = json['breakdown'] as Map<String, dynamic>;
    return RideBookingModel(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      rideType: RideTypeModel.fromJson(json['rideType'] as Map<String, dynamic>),
      pickupAddress: json['pickupAddress'] as String,
      dropAddress: json['dropAddress'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      etaMinutes: json['etaMinutes'] as int,
      driverName: driver['name'] as String,
      vehicle: driver['vehicle'] as String,
      plateNumber: driver['plateNumber'] as String,
      otpCode: json['otpCode'] as String?,
      fare: (breakdown['totalAmount'] as num).toDouble(),
      cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0,
      ratingStars: json['ratingStars'] as int?,
      paymentMethod: json['paymentMethod'] as String,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }
}
