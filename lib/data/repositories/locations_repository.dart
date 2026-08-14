import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/location_models.dart';

/// The user's saved address book.
///
/// Backend contract:
///  * `GET    /locations` → the user's addresses
///  * `POST   /locations { label, formattedAddress, lat, lng, isDefault? }`
///  * `PATCH  /locations/:id` → rename or set as default (all fields optional)
///  * `DELETE /locations/:id`
///
/// The backend does **no geocoding** — coordinates are the client's to supply.
class LocationsRepository {
  LocationsRepository(this._client);

  final ApiClient _client;

  Future<List<AddressModel>> getAddresses() async {
    final data = await _client.get(ApiEndpoints.locations) as List;
    return data
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves a new address. Coordinates are resolved client-side; callers
  /// without device geolocation pass an approximate city-center fallback.
  Future<AddressModel> addAddress({
    required String label,
    required String formattedAddress,
    required double lat,
    required double lng,
    bool? isDefault,
  }) async {
    final data = await _client.post(ApiEndpoints.locations, data: {
      'label': label,
      'formattedAddress': formattedAddress,
      'lat': lat,
      'lng': lng,
      'isDefault': ?isDefault,
    });
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  /// Renames an address and/or makes it the default. Every field is optional
  /// server-side, so only what changed is sent.
  Future<AddressModel> updateAddress(
    String id, {
    String? label,
    bool? isDefault,
  }) async {
    final data = await _client.patch(ApiEndpoints.location(id), data: {
      'label': ?label,
      'isDefault': ?isDefault,
    });
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String id) async {
    await _client.delete(ApiEndpoints.location(id));
  }
}
