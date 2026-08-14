/// One autocomplete prediction from `GET /places/search`.
///
/// Only [placeId] can be turned into coordinates — the texts are display-only,
/// so a suggestion is resolved with `GET /places/:placeId` once tapped.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.text,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;

  /// Full prediction, e.g. "Kakkanad, Kochi, Kerala, India".
  final String text;

  /// Emphasised part, e.g. "Kakkanad".
  final String mainText;

  /// Context line, e.g. "Kochi, Kerala, India".
  final String secondaryText;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        placeId: json['placeId'] as String,
        text: (json['text'] as String?) ?? '',
        mainText: (json['mainText'] as String?) ?? '',
        secondaryText: (json['secondaryText'] as String?) ?? '',
      );

  /// What to show when the backend sent no structured split.
  String get title => mainText.isNotEmpty ? mainText : text;
}

/// A coordinate resolved to named administrative levels.
///
/// Every level is nullable: Google does not name all of them everywhere, so a
/// rural coordinate often has no [locality]. Use [name] for a header label.
class ResolvedPlace {
  const ResolvedPlace({
    required this.placeId,
    required this.type,
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    this.locality,
    this.city,
    this.district,
    this.state,
    this.country,
  });

  final String? placeId;

  /// Finest level this result names: locality | city | district | state | country.
  final String type;
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;
  final String? locality;
  final String? city;
  final String? district;
  final String? state;
  final String? country;

  factory ResolvedPlace.fromJson(Map<String, dynamic> json) => ResolvedPlace(
        placeId: json['placeId'] as String?,
        type: (json['type'] as String?) ?? 'city',
        name: (json['name'] as String?) ?? '',
        formattedAddress: (json['formattedAddress'] as String?) ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        locality: json['locality'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
      );

  /// "Kakkanad, Kochi" — the two most useful levels, skipping nulls.
  String get shortAddress =>
      [locality, city].where((p) => p != null && p.isNotEmpty).join(', ');
}

/// A driving route from `GET /places/route`, for the line drawn on a map.
///
/// [points] arrive already decoded: the backend unpacks Google's encoded
/// polyline so only one codebase has to speak that format.
class MapRoute {
  const MapRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Route shape, origin first. At least two points.
  final List<({double lat, double lng})> points;
  final int distanceMeters;
  final int durationSeconds;

  factory MapRoute.fromJson(Map<String, dynamic> json) => MapRoute(
        points: (json['points'] as List)
            .map((p) => (
                  lat: ((p as List)[0] as num).toDouble(),
                  lng: (p[1] as num).toDouble(),
                ))
            .toList(),
        distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      );

  /// "4.2 km" — the distance as the map chip shows it.
  String get distanceLabel => '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  /// "18 min", rounded up so a 61-second leg never reads "1 min".
  String get durationLabel => '${(durationSeconds / 60).ceil()} min';
}
