import '../models/ad_models.dart';
import '../models/rental_models.dart';

/// Maps seller listings onto the Car Rental screen's own models.
///
/// Unlike cleaning and repair, a rental has no cart: one car is booked for a
/// date range. The catalogue translation lives here; the range itself becomes
/// an order's `scheduledAt`/`endAt` pair.
class RentalAdsAdapter {
  const RentalAdsAdapter._();

  /// The backend category whose listings this screen shows.
  static const categorySlug = 'car_rental';

  /// The filter chips across the top of the screen.
  static const _typeLabels = <String, String>{
    'SEDAN': 'Sedan',
    'SUV': 'SUV',
    'LUXURY': 'Luxury',
  };

  /// Which chip a listing sits under. Anything unlabelled reads as a sedan,
  /// the commonest class, rather than dropping off the screen.
  static String typeOf(AdModel ad) {
    final slug = ad.attribute<String>('subCategory');
    return slug != null && _typeLabels.containsKey(slug) ? slug : 'SEDAN';
  }

  /// One listing as a rentable car.
  ///
  /// The seeded catalogue drew each car from a small set of SVGs keyed by
  /// class; a seller's photo is not one of those, so the class icon still
  /// stands in when the card has no image.
  static RentalCarModel car(AdModel ad) {
    final type = typeOf(ad);
    return RentalCarModel(
      id: ad.id,
      name: ad.title,
      type: _typeLabels[type]!,
      // Written by sellers as MANUAL/AUTOMATIC; the card shows prose.
      transmission: switch (ad.attribute<String>('transmission')) {
        'MANUAL' => 'Manual',
        'AUTOMATIC' => 'Automatic',
        _ => '',
      },
      seats: ad.attribute<int>('seats') ?? 0,
      icon: ad.icon,
      pricePerDay: ad.price,
      category: type,
      iconKey: switch (type) {
        'SUV' => 'rental_suv',
        'LUXURY' => 'rental_luxury',
        _ => 'rental_sedan',
      },
      fuel: switch (ad.attribute<String>('fuel')) {
        'PETROL' => 'Petrol',
        'DIESEL' => 'Diesel',
        'ELECTRIC' => 'Electric',
        'HYBRID' => 'Hybrid',
        _ => '',
      },
      // The seeded cars carried a hand-set rating and a "BEST DEAL" ribbon.
      // Sellers set neither, so engagement stands in for both rather than the
      // screen inventing a score nobody gave.
      isBestDeal: ad.wishlistCount >= 5,
      badge: ad.wishlistCount >= 5 ? 'BEST DEAL' : null,
    );
  }

  /// The catalogue, optionally narrowed to one filter chip.
  ///
  /// `typeFilter` is the label the chip shows ("SUV"), or "All".
  static List<RentalCarModel> cars(List<AdModel> ads, {String typeFilter = 'All'}) {
    final wanted = _typeLabels.entries
        .where((e) => e.value.toLowerCase() == typeFilter.toLowerCase())
        .map((e) => e.key)
        .firstOrNull;
    final matching = wanted == null ? ads : ads.where((a) => typeOf(a) == wanted);
    return [for (final ad in matching) car(ad)];
  }

  /// The chips to offer, given what is actually listed. "All" always leads.
  static List<String> typeFilters(List<AdModel> ads) {
    final present = ads.map(typeOf).toSet();
    return [
      'All',
      for (final entry in _typeLabels.entries)
        if (present.contains(entry.key)) entry.value,
    ];
  }
}
