import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/offer_models.dart';

/// Reward-points summary plus the active offer banners.
///
/// Backend contract:
///  * `GET /offers` → `{ rewardPoints, rewardDiscountLabel, offers[] }`
///
/// `POST /offers` is ADMIN-only — banners are curated by ops, not the app.
class OffersRepository {
  OffersRepository(this._client);

  final ApiClient _client;

  Future<OffersPageModel> getOffers() async {
    final data = await _client.get(ApiEndpoints.offers);
    return OffersPageModel.fromJson(data as Map<String, dynamic>);
  }
}
