import '../widgets/live_map_view.dart';

/// One end of a trip: the address the user chose, plus its coordinate when we
/// have one.
///
/// Taxi and Porter used to keep the address string alone and throw the
/// coordinates away, which left nothing to draw a map with — and meant a
/// hand-typed address and a picked one were indistinguishable.
///
/// [lat]/[lng] are null for an address the user typed by hand, so callers must
/// check [hasCoordinates] before mapping it.
class TripPoint {
  const TripPoint({required this.address, this.lat, this.lng});

  const TripPoint.empty()
      : address = '',
        lat = null,
        lng = null;

  final String address;
  final double? lat;
  final double? lng;

  bool get isEmpty => address.isEmpty;
  bool get isNotEmpty => address.isNotEmpty;
  bool get hasCoordinates => lat != null && lng != null;

  /// A map pin for this point, or null when it has no coordinate.
  MapPoint? toMapPoint(MapPointKind kind) => hasCoordinates
      ? MapPoint(lat: lat!, lng: lng!, kind: kind, label: address)
      : null;

  @override
  bool operator ==(Object other) =>
      other is TripPoint &&
      other.address == address &&
      other.lat == lat &&
      other.lng == lng;

  @override
  int get hashCode => Object.hash(address, lat, lng);
}
