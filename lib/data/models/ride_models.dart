/// A ride-type option on the Taxi screen (Auto, Economy, Premium).
class RideTypeModel {
  const RideTypeModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
  });

  final String id;
  final String emoji;
  final String name;
  final double price;

  factory RideTypeModel.fromJson(Map<String, dynamic> json) => RideTypeModel(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );
}

/// Pickup / drop-off location for the Taxi screen.
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

/// Result returned after requesting a ride / driver search.
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
}
