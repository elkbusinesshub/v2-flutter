import 'package:elk/core/location/trip_point.dart';
import 'package:elk/core/widgets/live_map_view.dart';
import 'package:elk/data/models/place_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripPoint', () {
    test('an empty point has no address and nothing to map', () {
      const point = TripPoint.empty();

      expect(point.isEmpty, isTrue);
      expect(point.hasCoordinates, isFalse);
      expect(point.toMapPoint(MapPointKind.pickup), isNull);
    });

    test('a hand-typed address is usable but not mappable', () {
      // The picker returns no coordinates for text the user typed itself, and
      // guessing one would put a pin somewhere they never chose.
      const point = TripPoint(address: 'Behind the old post office');

      expect(point.isNotEmpty, isTrue);
      expect(point.hasCoordinates, isFalse);
      expect(point.toMapPoint(MapPointKind.drop), isNull);
    });

    test('a picked address becomes a pin of the requested kind', () {
      const point = TripPoint(
        address: 'Koramangala, Bengaluru',
        lat: 12.9352,
        lng: 77.6245,
      );

      final pin = point.toMapPoint(MapPointKind.pickup);

      expect(pin, isNotNull);
      expect(pin!.lat, 12.9352);
      expect(pin.lng, 77.6245);
      expect(pin.kind, MapPointKind.pickup);
      expect(pin.label, 'Koramangala, Bengaluru');
    });

    test('equality covers the coordinate, not just the text', () {
      // Two points can read the same and be different places — the map has to
      // refetch its route when that happens.
      const a = TripPoint(address: 'MG Road', lat: 12.9756, lng: 77.6068);
      const b = TripPoint(address: 'MG Road', lat: 19.0330, lng: 72.8290);

      expect(a == b, isFalse);
      expect(a == const TripPoint(address: 'MG Road', lat: 12.9756, lng: 77.6068),
          isTrue);
    });
  });

  group('MapRoute', () {
    test('parses the decoded points the backend sends', () {
      // The backend unpacks Google's encoded polyline, so the app never sees
      // that format.
      final route = MapRoute.fromJson(const {
        'points': [
          [12.9716, 77.5946],
          [12.9600, 77.6000],
          [12.9352, 77.6245],
        ],
        'distanceMeters': 8340,
        'durationSeconds': 907,
      });

      expect(route.points, hasLength(3));
      expect(route.points.first.lat, 12.9716);
      expect(route.points.last.lng, 77.6245);
    });

    test('labels the distance in km and rounds the ETA up', () {
      final route = MapRoute.fromJson(const {
        'points': [
          [0, 0],
          [1, 1],
        ],
        'distanceMeters': 4234,
        // 61 seconds must not read "1 min".
        'durationSeconds': 61,
      });

      expect(route.distanceLabel, '4.2 km');
      expect(route.durationLabel, '2 min');
    });

    test('tolerates a route with no distance or duration', () {
      final route = MapRoute.fromJson(const {
        'points': [
          [0, 0],
          [1, 1],
        ],
      });

      expect(route.distanceMeters, 0);
      expect(route.durationSeconds, 0);
    });
  });
}
