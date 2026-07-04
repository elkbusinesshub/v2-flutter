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
  });

  final String id;
  final String name;
  final String type;
  final String transmission;
  final int seats;
  final String icon;
  final double pricePerDay;
  final bool isBestDeal;

  factory RentalCarModel.fromJson(Map<String, dynamic> json) =>
      RentalCarModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        transmission: json['transmission'] as String,
        seats: json['seats'] as int,
        icon: json['icon'] as String,
        pricePerDay: (json['pricePerDay'] as num).toDouble(),
        isBestDeal: json['isBestDeal'] as bool? ?? false,
      );
}

enum RentalPeriod { daily, weekly, monthly }
