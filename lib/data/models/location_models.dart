/// A saved address from the backend address book (`/locations`).
class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String formattedAddress;
  final double lat;
  final double lng;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String,
        label: json['label'] as String,
        formattedAddress: json['formattedAddress'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        isDefault: (json['isDefault'] as bool?) ?? false,
      );
}
