import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/home_models.dart';
import '../models/provider_models.dart';
import '../models/service_models.dart';

class HomeRepository {
  HomeRepository(this._client);

  final ApiClient _client;

  Future<HomeFeedModel> getHomeFeed() {
    return _client.simulate('/home/feed', () {
      final json = dummyHomeFeedJson;
      return HomeFeedModel(
        userName: json['userName'] as String,
        location: json['location'] as String,
        promo: PromoBannerModel.fromJson(json['promo'] as Map<String, dynamic>),
        categories: (json['categories'] as List)
            .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        bestSellers: (json['bestSellers'] as List)
            .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    });
  }
}
