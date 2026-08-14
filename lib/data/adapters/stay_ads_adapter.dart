import '../models/ad_models.dart';
import '../models/stay_models.dart';

/// Maps seller listings onto the ELK Stay screens' own models.
///
/// A stay differs from the other verticals in two ways: it is priced per
/// month rather than per job, and it takes a deposit on top. Both come from
/// the listing — `price` is the rent, `depositAmount` is an attribute.
class StayAdsAdapter {
  const StayAdsAdapter._();

  /// The backend category whose listings these screens show.
  static const categorySlug = 'elkstay';

  /// Card gradients, one per property type, so the grid keeps the look it had
  /// when every stay carried a hand-set pair of colours.
  static const _gradients = <StayCategoryType, (int, int)>{
    StayCategoryType.pgStay: (0xFF1C5044, 0xFF2E7D6B),
    StayCategoryType.mensHostel: (0xFF1D3A5F, 0xFF2E5C8A),
    StayCategoryType.womensHostel: (0xFF5F1D4A, 0xFF8A2E6F),
    StayCategoryType.homestay: (0xFF5F401D, 0xFF8A6B2E),
  };

  static const _emoji = <StayCategoryType, String>{
    StayCategoryType.pgStay: '🏠',
    StayCategoryType.mensHostel: '🏢',
    StayCategoryType.womensHostel: '🏨',
    StayCategoryType.homestay: '🏡',
  };

  /// Which property type a listing is. Anything unlabelled reads as a PG,
  /// the commonest kind, rather than dropping off the screen.
  static StayCategoryType typeOf(AdModel ad) => switch (ad.attribute<String>('stayType')) {
        'MENS_HOSTEL' => StayCategoryType.mensHostel,
        'WOMENS_HOSTEL' => StayCategoryType.womensHostel,
        'HOMESTAY' => StayCategoryType.homestay,
        _ => StayCategoryType.pgStay,
      };

  /// The deposit a seller asks for on top of the monthly rent.
  static int depositOf(AdModel ad) => ad.attribute<int>('depositAmount') ?? 0;

  /// One listing as a property card.
  static StayModel stay(AdModel ad) {
    final type = typeOf(ad);
    final gradient = _gradients[type]!;
    return StayModel(
      id: ad.id,
      name: ad.title,
      categoryType: type,
      // Sellers cannot set a ribbon, so a well-saved listing earns one and the
      // rest carry none rather than the screen inventing a label.
      badge: ad.wishlistCount >= 5 ? 'POPULAR' : '',
      roomType: ad.attribute<String>('roomType') ?? '',
      location: ad.location,
      fullAddress: ad.location,
      // Nothing computes a distance; the card shows none rather than a
      // made-up figure.
      distanceKm: 0,
      pricePerMonth: ad.price.round(),
      // Earned, not seeded: the average of the reviews left on this
      // listing's completed orders. Zero means nobody has rated it yet.
      rating: ad.ratingAverage,
      // Verification was an admin flag on `stays`. Nothing grants it now.
      isVerified: false,
      amenities: [
        if (ad.attribute<bool>('furnished') == true)
          const StayAmenity(iconKey: 'furnished', label: 'Furnished'),
      ],
      description: ad.description,
      gradientStart: gradient.$1,
      gradientEnd: gradient.$2,
    );
  }

  /// The property-type tiles, counted from what is actually listed. Types
  /// nobody offers are left out rather than shown as empty.
  static List<StayCategoryModel> categories(List<AdModel> ads) {
    final counts = <StayCategoryType, int>{};
    for (final ad in ads) {
      counts.update(typeOf(ad), (n) => n + 1, ifAbsent: () => 1);
    }
    return [
      for (final type in StayCategoryType.values)
        if (counts[type] != null)
          StayCategoryModel(
            type: type,
            name: type.displayName,
            count: counts[type]!,
            gradientStart: _gradients[type]!.$1,
            gradientEnd: _gradients[type]!.$2,
            emoji: _emoji[type]!,
          ),
    ];
  }

  /// The listings, optionally narrowed to one property type.
  static List<StayModel> stays(List<AdModel> ads, {StayCategoryType? type}) => [
        for (final ad in ads)
          if (type == null || typeOf(ad) == type) stay(ad),
      ];

  /// A listing's detail page.
  ///
  /// The seeded stays offered several room options at different rents. A
  /// listing is one room at one rent, so the single option is built from the
  /// listing itself rather than left empty — the detail screen prices the
  /// booking from it.
  static StayDetailModel detail(AdModel ad) => StayDetailModel(
        stay: stay(ad),
        isSaved: ad.isWishlisted,
        roomOptions: [
          StayRoomOption(
            id: ad.id,
            kind: ad.attribute<String>('roomType') ?? 'Room',
            subtitle: ad.location,
            pricePerMonth: ad.price.round(),
          ),
        ],
      );
}
