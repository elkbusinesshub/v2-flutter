class PorterVehicleModel {
  const PorterVehicleModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.capacity,
  });

  final String id;
  final String emoji;
  final String name;
  final String capacity;

  factory PorterVehicleModel.fromJson(Map<String, dynamic> json) =>
      PorterVehicleModel(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        name: json['name'] as String,
        capacity: json['capacity'] as String,
      );
}

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

class PorterPageModel {
  const PorterPageModel({
    required this.vehicles,
    required this.route,
  });

  final List<PorterVehicleModel> vehicles;
  final PorterRouteModel route;
}
