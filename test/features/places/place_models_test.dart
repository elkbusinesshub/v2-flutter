import 'package:flutter_test/flutter_test.dart';

import 'package:elk/data/models/place_models.dart';

void main() {
  group('PlaceSuggestion', () {
    test('parses an autocomplete prediction', () {
      final suggestion = PlaceSuggestion.fromJson({
        'placeId': 'ChIJB3qglI4MCDsRYCbo-s0hmQQ',
        'text': 'Kakkanad, Kerala, India',
        'mainText': 'Kakkanad',
        'secondaryText': 'Kerala, India',
      });

      expect(suggestion.placeId, 'ChIJB3qglI4MCDsRYCbo-s0hmQQ');
      expect(suggestion.title, 'Kakkanad');
      expect(suggestion.secondaryText, 'Kerala, India');
    });

    test('falls back to the full text when Google sent no structured split', () {
      final suggestion = PlaceSuggestion.fromJson({
        'placeId': 'ChIJa',
        'text': 'Kakkanad Junction, Kochi',
        'mainText': '',
        'secondaryText': '',
      });

      expect(suggestion.title, 'Kakkanad Junction, Kochi');
    });
  });

  group('ResolvedPlace', () {
    test('parses the full backend payload', () {
      final place = ResolvedPlace.fromJson({
        'placeId': 'ChIJj42uPYsMCDsR5ed6Qby_lhs',
        'type': 'locality',
        'name': 'Kusumagiri',
        'formattedAddress': '15/355, Echamuku, Kusumagiri, Kakkanad, Kerala 682030, India',
        'lat': 10.015861,
        'lng': 76.341867,
        'locality': 'Kusumagiri',
        'city': 'Kakkanad',
        'district': 'Ernakulam',
        'state': 'Kerala',
        'country': 'India',
      });

      expect(place.type, 'locality');
      expect(place.lat, 10.015861);
      expect(place.city, 'Kakkanad');
      expect(place.shortAddress, 'Kusumagiri, Kakkanad');
    });

    test('keeps levels the backend left null', () {
      final place = ResolvedPlace.fromJson({
        'placeId': null,
        'type': 'city',
        'name': 'Kochi',
        'formattedAddress': 'Kochi, Kerala, India',
        'lat': 9.9312,
        'lng': 76.2673,
        'locality': null,
        'city': 'Kochi',
        'district': null,
        'state': 'Kerala',
        'country': 'India',
      });

      expect(place.placeId, isNull);
      expect(place.locality, isNull);
      expect(place.district, isNull);
      // A missing level is skipped rather than leaving a dangling comma.
      expect(place.shortAddress, 'Kochi');
    });

    test('survives a payload with only the required coordinates', () {
      final place = ResolvedPlace.fromJson({'lat': 10, 'lng': 76});

      expect(place.lat, 10.0);
      expect(place.type, 'city');
      expect(place.name, '');
      expect(place.shortAddress, '');
    });
  });
}
