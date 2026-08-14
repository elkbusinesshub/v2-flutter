import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/service_models.dart';

/// Service catalog against the ELK backend.
///
/// Backend contract:
///  * `GET /services` → catalog grouped by category
///  * `GET /services/:id` → full detail for one service
class ServicesRepository {
  ServicesRepository(this._client);

  final ApiClient _client;

  /// The full service catalogue, grouped by category.
  ///
  /// Currently uncalled: `ServicesCubit` was deleted in Feature 37 as
  /// unreachable, and `/services` renders a hardcoded category grid. Kept
  /// because `GET /services` is live and this is its only client binding —
  /// `getServiceDetail` below is what the app actually uses.
  Future<List<ServiceGroupModel>> getServiceGroups() async {
    final data = await _client.get(ApiEndpoints.services) as List;
    return data
        .map((e) => ServiceGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceDetailModel> getServiceDetail(String serviceId) async {
    final data = await _client.get(ApiEndpoints.serviceDetail(serviceId));
    return ServiceDetailModel.fromJson(data as Map<String, dynamic>);
  }
}
