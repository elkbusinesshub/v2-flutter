import '../../core/api/api_client.dart';
import '../../core/l10n/l10n.dart';
import '../../core/api/api_endpoints.dart';
import '../models/home_models.dart';
import '../models/service_models.dart';

/// The aggregated Home screen payload.
///
/// Backend contract: `GET /home/feed` →
/// `{ userName, location, promo, categories, bestSellers }`.
class HomeRepository {
  HomeRepository(this._client);

  final ApiClient _client;

  Future<HomeFeedModel> getHomeFeed() async {
    final data = await _client.get(ApiEndpoints.homeFeed);
    return HomeFeedModel.fromJson(data as Map<String, dynamic>);
  }

  /// Local feed for guest mode — `/home/feed` requires a session, and the
  /// tiles/promo are static config mirrored from the backend's HomeService.
  HomeFeedModel guestFeed() {
    final l10n = L10n.current;
    return HomeFeedModel(
      userName: l10n.guest,
      location: '',
      promo: PromoBannerModel(
        title: l10n.promoTwentyOffFirstBooking,
        subtitle: l10n.promoFirstBookingBody,
        ctaLabel: l10n.claimOfferArrow,
        tag: l10n.homeBadgeNew,
        icon: '🎁',
      ),
      categories: [
        ServiceCategoryModel(id: 'taxi', name: l10n.catTaxiRide, icon: '🚕', colorHex: 0xFFE0F7F5),
        const ServiceCategoryModel(id: 'elkstay', name: 'ELK Stay', icon: '🏨', colorHex: 0xFFE6EFEA),
        ServiceCategoryModel(id: 'cleaning', name: l10n.svcCleaning, icon: '🧹', colorHex: 0xFFFEF3C7),
        ServiceCategoryModel(id: 'car_rental', name: l10n.svcCarRental, icon: '🚗', colorHex: 0xFFEDE9FE),
        ServiceCategoryModel(id: 'repair', name: l10n.svcRepair, icon: '🔧', colorHex: 0xFFFCE7F3),
        ServiceCategoryModel(id: 'porter', name: l10n.catPorter, icon: '📦', colorHex: 0xFFD1FAE5),
      ],
      bestSellers: const [],
    );
  }
}
