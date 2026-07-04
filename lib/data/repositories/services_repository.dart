import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/service_models.dart';

class ServicesRepository {
  ServicesRepository(this._client);

  final ApiClient _client;

  Future<List<ServiceGroupModel>> getServiceGroups() {
    return _client.simulate(
      '/services',
      () => dummyServiceGroupsJson
          .map((e) => ServiceGroupModel.fromJson(e))
          .toList(),
    );
  }

  Future<ServiceDetailModel> getServiceDetail(String serviceId) {
    return _client.simulate(
      '/services/$serviceId',
      () => ServiceDetailModel.fromJson(dummyServiceDetailJson),
    );
  }
}
