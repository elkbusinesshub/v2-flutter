import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/ride_models.dart';

class RideRepository {
  RideRepository(this._client);

  final ApiClient _client;

  Future<List<RideTypeModel>> getRideTypes() {
    return _client.simulate(
      '/rides/types',
      () => dummyRideTypesJson.map((e) => RideTypeModel.fromJson(e)).toList(),
    );
  }

  Future<TaxiLocationModel> getCurrentTrip() {
    return _client.simulate(
      '/rides/current-estimate',
      () => TaxiLocationModel.fromJson(dummyTaxiLocationJson),
    );
  }

  Future<DriverMatchModel> findDrivers(String rideTypeId) {
    return _client.simulateMutation(
      '/rides/request',
      {'rideTypeId': rideTypeId},
      () => const DriverMatchModel(
        driverName: 'Yusuf Khan',
        vehicle: 'Toyota Corolla · White',
        plateNumber: 'DXB 4471',
        etaMinutes: 4,
      ),
      delay: const Duration(milliseconds: 1200),
    );
  }
}
