import '../models/ad_models.dart';
import '../models/elkclean_models.dart';

/// Maps seller listings onto the ELK Clean screen's own models.
///
/// The screen and its models are unchanged: sellers replaced the seeded
/// `clean_services` catalogue as the source of what is bookable, but a
/// cleaning job still displays as a tile, a duration and a checklist. This
/// file is the whole of that translation, so the 1,400-line shell never learns
/// that its data now comes from `/marketplace/ads`.
class CleanAdsAdapter {
  const CleanAdsAdapter._();

  /// The backend category whose listings this screen shows.
  static const categorySlug = 'cleaning';

  /// The tiles on the home grid, keyed by the `subCategory` attribute a seller
  /// picks when posting. Held here rather than fetched because each carries a
  /// drawn icon: a slug with no asset would render an empty tile.
  static const _tiles = <String, ({String code, String label, String blurb, String iconKey})>{
    'cln': (
      code: 'CLN',
      label: 'Home Cleaning',
      blurb: 'Standard, deep & move-out',
      iconKey: 'ic_home_clean'
    ),
    'deep': (
      code: 'DCP',
      label: 'Deep Cleaning',
      blurb: 'Top-to-bottom detail clean',
      iconKey: 'ic_deep_clean'
    ),
    'tnk': (
      code: 'TNK',
      label: 'Water Tank',
      blurb: 'Drain, scrub & disinfect',
      iconKey: 'ic_water_tank'
    ),
    'sof': (
      code: 'SOF',
      label: 'Sofa & Upholstery',
      blurb: 'Shampoo & protect',
      iconKey: 'ic_sofa'
    ),
    'crp': (code: 'CRP', label: 'Carpet & Rug', blurb: 'Steam deep clean', iconKey: 'ic_carpet'),
    'kit': (code: 'KIT', label: 'Kitchen Clean', blurb: 'Degrease & sanitise', iconKey: 'ic_kitchen'),
    'bth': (code: 'BTH', label: 'Bathroom Clean', blurb: 'Sanitise & descale', iconKey: 'ic_bath'),
    'lndr': (
      code: 'LND',
      label: 'Laundry & Iron',
      blurb: 'Wash, dry & press',
      iconKey: 'ic_laundry'
    ),
  };

  /// Where a listing sits on the grid. Listings posted without a sub-category
  /// fall under Home Cleaning rather than vanishing from the screen.
  static String subCategoryOf(AdModel ad) {
    final slug = ad.attribute<String>('subCategory');
    return slug != null && _tiles.containsKey(slug) ? slug : 'cln';
  }

  /// Tiles for the categories that actually have listings, most-stocked first.
  ///
  /// An empty tile would be a dead end — the grid reflects what sellers are
  /// offering, not a fixed menu.
  static List<CleanCategoryModel> categories(List<AdModel> ads) {
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
        CleanCategoryModel(
          slug: slug,
          code: _tiles[slug]!.code,
          label: _tiles[slug]!.label,
          blurb: _tiles[slug]!.blurb,
          iconKey: _tiles[slug]!.iconKey,
          // The seeded catalogue starred and badged tiles by hand; sellers
          // have no way to, so the grid shows neither rather than inventing.
          serviceCount: counts[slug]!,
        ),
    ];
  }

  /// One listing as a bookable service.
  static CleanServiceModel service(AdModel ad) => CleanServiceModel(
        id: ad.id,
        // The seeded catalogue had SKUs like CLN-01. A listing has no such
        // number, so the seller's name stands in as the identifying line.
        code: ad.sellerName,
        name: ad.title,
        description: ad.description,
        // Listings price in rupees with paise available; this screen has
        // always shown whole rupees.
        price: ad.price.round(),
        duration: ad.attribute<String>('durationLabel') ?? '',
        // "Popular" came from a curated flag. Engagement is the honest
        // equivalent now that ranking is by wishlists.
        tag: ad.wishlistCount >= 5 ? 'Popular' : null,
        checklist: (ad.attributes['includes'] as List?)?.cast<String>() ?? const [],
      );

  /// Listings under one tile, as services.
  static List<CleanServiceModel> servicesIn(List<AdModel> ads, String subCategory) =>
      [for (final ad in ads.where((a) => subCategoryOf(a) == subCategory)) service(ad)];
}
