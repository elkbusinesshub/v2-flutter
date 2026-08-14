import 'dart:typed_data';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/place_models.dart';

/// Address lookup, proxied by the backend so the Google key never ships in the
/// app bundle.
///
/// Backend contract:
///  * `GET /places/search?query=` → autocomplete predictions
///  * `GET /places/:placeId`      → the picked suggestion, with coordinates
///  * `GET /places/reverse?lat=&lng=` → "where am I"
///  * `GET /places/static-map?lat=&lng=` → a map image (PNG bytes)
///  * `GET /places/route?originLat=&…` → the driving route between two points
///
/// All of them require a signed-in user — the endpoints proxy a metered Google
/// account, so guests never reach them.
class PlacesRepository {
  PlacesRepository(this._client);

  final ApiClient _client;

  Future<List<PlaceSuggestion>> search(String query) async {
    final data = await _client.get(
      ApiEndpoints.placeSearch,
      queryParameters: {'query': query},
    ) as List;
    return data
        .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Resolves a suggestion the user tapped into coordinates and named levels.
  Future<ResolvedPlace> details(String placeId) async {
    final data = await _client.get(ApiEndpoints.placeDetails(placeId));
    return ResolvedPlace.fromJson(data as Map<String, dynamic>);
  }

  /// Names the device's current coordinate.
  Future<ResolvedPlace> reverse({
    required double lat,
    required double lng,
  }) async {
    final data = await _client.get(
      ApiEndpoints.placeReverse,
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return ResolvedPlace.fromJson(data as Map<String, dynamic>);
  }

  /// The driving route between two points, for the polyline on a map.
  ///
  /// Null when the backend found no road route — callers draw a straight line
  /// rather than nothing.
  Future<MapRoute?> route({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final data = await _client.get(
      ApiEndpoints.placeRoute,
      queryParameters: {
        'originLat': originLat,
        'originLng': originLng,
        'destLat': destLat,
        'destLng': destLng,
      },
    );
    if (data == null) return null;
    return MapRoute.fromJson(data as Map<String, dynamic>);
  }

  /// Map imagery for a coordinate, as PNG bytes.
  ///
  /// Proxied like the rest: the Google key never ships in the app bundle. The
  /// backend caches each image for 30 days, so repeat views are free.
  /// Map imagery for a coordinate, as PNG bytes.
  ///
  /// Currently uncalled: every map surface moved to the interactive
  /// `LiveMapView` (Feature 36), and Maps Static API is disabled on the Google
  /// project anyway. Kept because `GET /places/static-map` is live and this is
  /// its only client binding.
  Future<Uint8List> staticMap({
    required double lat,
    required double lng,
    int zoom = 15,
    int width = 400,
    int height = 200,
  }) {
    return _client.getBytes(
      ApiEndpoints.placeStaticMap,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'zoom': zoom,
        'width': width,
        'height': height,
      },
    );
  }
}
