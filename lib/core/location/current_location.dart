import 'package:geolocator/geolocator.dart';

import '../../data/models/place_models.dart';
import '../../data/repositories/places_repository.dart';
import '../l10n/l10n.dart';

/// Raised when the device cannot give us a coordinate. [message] is already
/// written for the user.
class LocationUnavailable implements Exception {
  const LocationUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Reads the device GPS and names the coordinate through the backend.
///
/// Permission is requested here rather than at startup so the prompt has
/// obvious context — the user has just tapped "use current location".
///
/// Shared so every screen that offers "use my location" gets the same
/// behaviour; the alternative was each one inventing its own, which is how
/// Car Rental ended up hardcoding an address instead of reading GPS.
Future<ResolvedPlace> resolveCurrentLocation(PlacesRepository places) async {
  final l10n = L10n.current;

  if (!await Geolocator.isLocationServiceEnabled()) {
    throw LocationUnavailable(l10n.turnOnLocationServices);
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw LocationUnavailable(l10n.locationPermissionNeeded);
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
  );

  return places.reverse(lat: position.latitude, lng: position.longitude);
}

/// Asks for location permission once, at first launch.
///
/// Returns whether we ended up with permission. Deliberately swallows every
/// failure: a declined prompt must not block onboarding, and the in-context
/// request in [resolveCurrentLocation] asks again later if needed.
Future<bool> requestLocationPermissionOnce() async {
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  } catch (_) {
    return false;
  }
}
