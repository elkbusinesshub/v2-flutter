/// Models for the porter/delivery vertical (backend `/porter/*`).
///
/// The backend emits the legacy fields (`id`, `emoji`, `name`, `capacity`)
/// plus the richer vehicle-card fields, so one model serves both.
class PorterVehicleModel {
  const PorterVehicleModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.capacity,
    this.iconKey = '',
    this.etaMinutes = 0,
    this.baseFare = 0,
    this.badge,
  });

  /// Wire slug, e.g. `bike` — sent as `vehicleId`.
  final String id;
  final String emoji;
  final String name;
  final String capacity;
  final String iconKey;
  final int etaMinutes;
  final double baseFare;
  final String? badge;

  String get svgAsset => 'assets/icons/$iconKey.svg';

  factory PorterVehicleModel.fromJson(Map<String, dynamic> json) =>
      PorterVehicleModel(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        name: json['name'] as String,
        capacity: json['capacity'] as String,
        iconKey: json['iconKey'] as String? ?? '',
        etaMinutes: (json['etaMinutes'] as int?) ?? 0,
        baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0,
        badge: json['badge'] as String?,
      );
}

/// An optional add-on (loading helper, fragile handling, insurance).
class PorterAddonModel {
  const PorterAddonModel({
    required this.id,
    required this.label,
    required this.price,
  });

  /// Wire key sent in `addons: [...]`.
  final String id;
  final String label;
  final double price;

  factory PorterAddonModel.fromJson(Map<String, dynamic> json) =>
      PorterAddonModel(
        id: json['id'] as String,
        label: json['label'] as String,
        price: (json['price'] as num).toDouble(),
      );
}

/// The static route estimate card shown above the vehicle picker.
class PorterRouteModel {
  const PorterRouteModel({
    required this.pickupLabel,
    required this.pickupAddress,
    required this.dropLabel,
    required this.dropAddress,
    required this.packageType,
    required this.weight,
    required this.estimatedFare,
    required this.distanceKm,
    required this.etaMinutes,
  });

  final String pickupLabel;
  final String pickupAddress;
  final String dropLabel;
  final String dropAddress;
  final String packageType;
  final String weight;
  final double estimatedFare;
  final double distanceKm;
  final int etaMinutes;

  factory PorterRouteModel.fromJson(Map<String, dynamic> json) =>
      PorterRouteModel(
        pickupLabel: json['pickupLabel'] as String,
        pickupAddress: json['pickupAddress'] as String,
        dropLabel: json['dropLabel'] as String,
        dropAddress: json['dropAddress'] as String,
        packageType: json['packageType'] as String,
        weight: json['weight'] as String,
        estimatedFare: (json['estimatedFare'] as num).toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        etaMinutes: json['etaMinutes'] as int,
      );
}

/// `GET /porter/options` — everything the booking screens need up front.
class PorterPageModel {
  const PorterPageModel({
    required this.vehicles,
    required this.route,
    this.addons = const [],
    this.pickupWindows = const [],
    this.serviceFee = 0,
    this.vatRate = 0,
  });

  final List<PorterVehicleModel> vehicles;
  final PorterRouteModel route;
  final List<PorterAddonModel> addons;

  /// "Schedule for later" windows, e.g. `9:00 – 10:00`.
  final List<String> pickupWindows;
  final double serviceFee;
  final double vatRate;

  factory PorterPageModel.fromJson(Map<String, dynamic> json) => PorterPageModel(
        vehicles: (json['vehicles'] as List)
            .map((e) => PorterVehicleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        route: PorterRouteModel.fromJson(json['route'] as Map<String, dynamic>),
        addons: (json['addons'] as List? ?? const [])
            .map((e) => PorterAddonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pickupWindows:
            (json['pickupWindows'] as List? ?? const []).cast<String>(),
        serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
        vatRate: (json['vatRate'] as num?)?.toDouble() ?? 0,
      );
}

/// Server-computed fare breakdown (quote and booking share this shape).
class PorterBreakdown {
  const PorterBreakdown({
    required this.baseFare,
    required this.addonsTotal,
    required this.serviceFee,
    required this.vatAmount,
    required this.totalAmount,
  });

  final double baseFare;
  final double addonsTotal;
  final double serviceFee;
  final double vatAmount;
  final double totalAmount;

  factory PorterBreakdown.fromJson(Map<String, dynamic> json) => PorterBreakdown(
        baseFare: (json['baseFare'] as num).toDouble(),
        addonsTotal: (json['addonsTotal'] as num).toDouble(),
        serviceFee: (json['serviceFee'] as num).toDouble(),
        vatAmount: (json['vatAmount'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
      );
}

/// A created (or listed) porter delivery.
class PorterBookingModel {
  const PorterBookingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.vehicle,
    required this.pickupAddress,
    required this.dropAddress,
    required this.breakdown,
    required this.paymentMethod,
    this.packageType,
    this.weightLabel,
    this.pickupWindow,
    this.scheduledAt,
    this.distanceKm = 0,
    this.etaMinutes = 0,
  });

  final String id;

  /// Tracking reference shown on the success ticket, e.g. `ELK-4821-QT`.
  final String code;
  final String status;
  final PorterVehicleModel vehicle;
  final String pickupAddress;
  final String dropAddress;
  final String? packageType;
  final String? weightLabel;
  final String? pickupWindow;
  final DateTime? scheduledAt;
  final double distanceKm;
  final int etaMinutes;
  final PorterBreakdown breakdown;
  final String paymentMethod;

  factory PorterBookingModel.fromJson(Map<String, dynamic> json) =>
      PorterBookingModel(
        id: json['id'] as String,
        code: json['code'] as String,
        status: json['status'] as String,
        vehicle:
            PorterVehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
        pickupAddress: json['pickupAddress'] as String,
        dropAddress: json['dropAddress'] as String,
        packageType: json['packageType'] as String?,
        weightLabel: json['weightLabel'] as String?,
        pickupWindow: json['pickupWindow'] as String?,
        scheduledAt: json['scheduledAt'] == null
            ? null
            : DateTime.parse(json['scheduledAt'] as String),
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        etaMinutes: (json['etaMinutes'] as int?) ?? 0,
        breakdown:
            PorterBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
        paymentMethod: json['paymentMethod'] as String,
      );
}
