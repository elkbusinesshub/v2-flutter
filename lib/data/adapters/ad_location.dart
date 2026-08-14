import '../models/ad_models.dart';

/// Where most of a set of listings are.
///
/// Each vertical's home header used to show the city its seeded catalogue
/// served. Listings carry their own locality, so the commonest one among them
/// is the honest answer to "where is this" — and it changes as sellers in a
/// new area start posting.
///
/// Empty when no listing has a location, in which case the header shows
/// nothing rather than a guess.
String commonestAdLocation(List<AdModel> ads) {
  final counts = <String, int>{};
  for (final ad in ads) {
    if (ad.location.isNotEmpty) {
      counts.update(ad.location, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  if (counts.isEmpty) return '';
  return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}
