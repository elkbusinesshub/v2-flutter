import '../models/ad_models.dart';
import '../models/service_models.dart';

/// Maps seller listings onto the Services screen's own models.
///
/// Unlike the four vertical adapters, this one is not scoped to a category —
/// the Services screen is the cross-category browse, so it groups every
/// listing by the category its seller chose. The groups it shows are whatever
/// people are actually offering.
class ServicesAdsAdapter {
  const ServicesAdsAdapter._();

  /// Display name and emoji per seller category, in the order the grid shows
  /// them. A category nobody has listed under is simply absent.
  static const _groups = <String, (String title, String icon)>{
    'cleaning': ('Cleaning', '🧹'),
    'repairing': ('Repairs', '🔧'),
    'car_rental': ('Car Rental', '🚗'),
    'elkstay': ('ELK Stay', '🏨'),
    'taxi': ('Taxi & Rides', '🚕'),
    'porter': ('Porter', '📦'),
  };

  /// Listings grouped by category, most-stocked group first.
  static List<ServiceGroupModel> groups(List<AdModel> ads) {
    final byCategory = <String, List<AdModel>>{};
    for (final ad in ads) {
      // A listing in a category with no display name still has to be
      // reachable, so it groups under its own slug rather than vanishing.
      byCategory.putIfAbsent(ad.categorySlug, () => []).add(ad);
    }

    final slugs = byCategory.keys.toList()
      ..sort((a, b) {
        final byCount = byCategory[b]!.length.compareTo(byCategory[a]!.length);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    return [
      for (final slug in slugs)
        ServiceGroupModel(
          title: _groups[slug]?.$1 ?? _titleise(slug),
          icon: _groups[slug]?.$2 ?? '🛍️',
          items: [
            for (final ad in byCategory[slug]!)
              ServiceSubItemModel(id: ad.id, name: ad.title, icon: ad.icon),
          ],
        ),
    ];
  }

  /// "ac_service" → "Ac service", for a category with no display name yet.
  static String _titleise(String slug) {
    final words = slug.replaceAll('_', ' ');
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }

  /// One listing as a service detail page.
  static ServiceDetailModel detail(AdModel ad) => ServiceDetailModel(
        id: ad.id,
        title: ad.title,
        // The seeded catalogue carried a curated ribbon. Engagement is the
        // honest equivalent now that ranking is by wishlists.
        badge: ad.wishlistCount >= 5 ? 'POPULAR' : '',
        providerName: ad.sellerName,
        providerInitials: _initials(ad.sellerName),
        // Sellers give no trading history, so the page shows none rather than
        // a length of service nobody claimed.
        providerExperience: '',
        rating: 0,
        reviewCount: 0,
        duration: ad.attribute<String>('durationLabel') ?? '',
        teamSize: '',
        category: _groups[ad.categorySlug]?.$1 ?? _titleise(ad.categorySlug),
        // "1.2k bookings" was a seeded display string. Views are a real
        // number the backend maintains, so the page shows that instead.
        bookings: '${ad.viewCount}',
        included: (ad.attributes['includes'] as List?)?.cast<String>() ?? const [],
        description: ad.description,
        price: ad.price,
        priceUnit: ad.priceUnit,
      );

  /// "Bright Spark Services" → "BS", for the provider avatar.
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
