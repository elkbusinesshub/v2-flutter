import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/porter_models.dart';

class PorterRepository {
  PorterRepository(this._client);

  final ApiClient _client;

  Future<PorterPageModel> getPorterOptions() {
    return _client.simulate('/porter/options', () {
      final json = dummyPorterJson;
      return PorterPageModel(
        vehicles: (json['vehicles'] as List)
            .map((e) => PorterVehicleModel.fromJson(e))
            .toList(),
        route: PorterRouteModel.fromJson(json['route'] as Map<String, dynamic>),
      );
    });
  }

  Future<String> bookPorter({required String vehicleId}) {
    return _client.simulateMutation(
      '/porter/bookings',
      {'vehicleId': vehicleId},
      () => '#ELK-2025-04922',
      delay: const Duration(milliseconds: 900),
    );
  }
}
