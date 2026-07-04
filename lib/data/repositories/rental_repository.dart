import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/rental_models.dart';

class RentalRepository {
  RentalRepository(this._client);

  final ApiClient _client;

  Future<List<RentalCarModel>> getCars({
    RentalPeriod period = RentalPeriod.daily,
    String typeFilter = 'All',
  }) {
    return _client.simulate('/rentals/cars', () {
      final cars =
          dummyRentalCarsJson.map((e) => RentalCarModel.fromJson(e)).toList();
      if (typeFilter == 'All') return cars;
      return cars.where((c) => c.type == typeFilter).toList();
    });
  }
}
