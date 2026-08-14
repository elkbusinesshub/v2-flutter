import '../models/ad_models.dart';
import '../models/elkrep_models.dart';

/// Maps seller listings onto the ELK Rep screen's own models.
///
/// The twin of [CleanAdsAdapter] — same shape, different vocabulary: a repair
/// job has a warranty where a clean has a checklist. Kept separate rather than
/// generified because the two screens' models are unrelated types and the
/// tile tables differ; sharing them would mean a layer of generics earning
/// nothing.
class RepairAdsAdapter {
  const RepairAdsAdapter._();

  /// The backend category whose listings this screen shows.
  static const categorySlug = 'repairing';

  /// The trades on the home grid, keyed by the `subCategory` attribute. Held
  /// here because each carries a drawn icon.
  static const _tiles = <String, ({String code, String label, String blurb, String iconKey})>{
    'ac': (code: 'AC', label: 'AC & Cooling', blurb: 'Service, gas, deep clean', iconKey: 'ic_ac'),
    'plm': (code: 'PLM', label: 'Plumbing', blurb: 'Leaks, taps, drains', iconKey: 'ic_plumb'),
    'elc': (
      code: 'ELC',
      label: 'Electrical',
      blurb: 'Wiring, fittings, faults',
      iconKey: 'ic_elec'
    ),
    'cpt': (
      code: 'CPT',
      label: 'Carpentry',
      blurb: 'Doors, furniture, fixes',
      iconKey: 'ic_carpentry'
    ),
    'pnt': (code: 'PNT', label: 'Painting', blurb: 'Walls, touch-ups', iconKey: 'ic_paint'),
    'gen': (
      code: 'GEN',
      label: 'Handyman',
      blurb: 'Odd jobs & mounting',
      iconKey: 'ic_handyman'
    ),
  };

  /// Which trade a listing sits under. Anything unlabelled falls to Handyman
  /// rather than disappearing from the screen.
  static String subCategoryOf(AdModel ad) {
    final slug = ad.attribute<String>('subCategory');
    return slug != null && _tiles.containsKey(slug) ? slug : 'gen';
  }

  /// Tiles for the trades that actually have listings, most-stocked first.
  static List<RepairCategoryModel> categories(List<AdModel> ads) {
    final counts = <String, int>{};
    for (final ad in ads) {
      counts.update(subCategoryOf(ad), (n) => n + 1, ifAbsent: () => 1);
    }

    final slugs = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    return [
      for (final slug in slugs)
        RepairCategoryModel(
          slug: slug,
          code: _tiles[slug]!.code,
          label: _tiles[slug]!.label,
          blurb: _tiles[slug]!.blurb,
          iconKey: _tiles[slug]!.iconKey,
          serviceCount: counts[slug]!,
        ),
    ];
  }

  /// One listing as a bookable job.
  static RepairServiceModel service(AdModel ad) => RepairServiceModel(
        id: ad.id,
        // A listing has no SKU; the seller's name is what identifies it.
        code: ad.sellerName,
        name: ad.title,
        description: ad.description,
        price: ad.price.round(),
        duration: ad.attribute<String>('durationLabel') ?? '',
        tag: ad.wishlistCount >= 5 ? 'Popular' : null,
        // The seeded catalogue's "what's included" was identical boilerplate on
        // every job. The warranty a seller offers is real, listing-specific
        // information, so it takes that slot instead.
        included: [
          if (ad.attribute<String>('warrantyLabel') case final warranty?) 'Warranty: $warranty',
        ],
      );

  /// Listings under one trade, as jobs.
  static List<RepairServiceModel> servicesIn(List<AdModel> ads, String subCategory) =>
      [for (final ad in ads.where((a) => subCategoryOf(a) == subCategory)) service(ad)];
}
