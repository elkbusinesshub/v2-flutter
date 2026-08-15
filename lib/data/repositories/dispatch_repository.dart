import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/dispatch_models.dart';

/// Drivers and delivery partners: who is out there, and the partner's own
/// duty state (`/dispatch/*`).
///
/// Backend contract:
///  * `GET  /dispatch/me` → the vehicles this account is registered to drive
///  * `POST /dispatch/register { service, vehicleSlug, vehicleLabel, plateNumber }`
///  * `POST /dispatch/online { service, isOnline, lat?, lng? }`
///  * `POST /dispatch/location { service, lat, lng }` → heartbeat
///  * `GET  /dispatch/nearby/{rides,porter}?lat&lng` → the map pins
class DispatchRepository {
  DispatchRepository(this._client);

  final ApiClient _client;

  // ─── the rider's side ───────────────────────────────────────────────────

  /// Partners on duty around a point.
  ///
  /// An empty list is a real answer, not a failure: it means nobody is out
  /// there right now, and the map should show no vehicles rather than invent
  /// some.
  Future<List<NearbyVehicleModel>> nearby({
    required DriverService service,
    required double lat,
    required double lng,
    String? vehicleSlug,
  }) async {
    final data = await _client.get(
      service == DriverService.ride
          ? ApiEndpoints.dispatchNearbyRides
          : ApiEndpoints.dispatchNearbyPorter,
      queryParameters: {'lat': lat, 'lng': lng, 'vehicleSlug': ?vehicleSlug},
    );
    return (data as List)
        .map((e) => NearbyVehicleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── the partner's side ─────────────────────────────────────────────────

  Future<List<DriverProfileModel>> myProfiles() async {
    final data = await _client.get(ApiEndpoints.dispatchProfiles);
    return (data as List)
        .map((e) => DriverProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DriverProfileModel> register({
    required DriverService service,
    required String vehicleSlug,
    required String vehicleLabel,
    required String plateNumber,
  }) async {
    final data = await _client.post(ApiEndpoints.dispatchRegister, data: {
      'service': service.wireValue,
      'vehicleSlug': vehicleSlug,
      'vehicleLabel': vehicleLabel,
      'plateNumber': plateNumber,
    });
    return DriverProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// Goes on or off duty. Sending the position alongside makes a partner
  /// dispatchable immediately rather than only after the first heartbeat.
  Future<DriverProfileModel> setOnline({
    required DriverService service,
    required bool isOnline,
    double? lat,
    double? lng,
  }) async {
    final data = await _client.post(ApiEndpoints.dispatchOnline, data: {
      'service': service.wireValue,
      'isOnline': isOnline,
      'lat': ?lat,
      'lng': ?lng,
    });
    return DriverProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// Where the partner is now. Also the heartbeat — stop sending these and
  /// dispatch stops offering work, without needing to be told.
  Future<void> sendLocation({
    required DriverService service,
    required double lat,
    required double lng,
  }) async {
    await _client.post(ApiEndpoints.dispatchLocation, data: {
      'service': service.wireValue,
      'lat': lat,
      'lng': lng,
    });
  }
}
