import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/offer_models.dart';

class OffersRepository {
  OffersRepository(this._client);

  final ApiClient _client;

  Future<OffersPageModel> getOffers() {
    return _client.simulate('/offers', () {
      final json = dummyOffersJson;
      return OffersPageModel(
        rewardPoints: json['rewardPoints'] as int,
        rewardDiscountLabel: json['rewardDiscountLabel'] as String,
        offers: (json['offers'] as List)
            .map((e) => OfferModel.fromJson(e))
            .toList(),
      );
    });
  }
}
