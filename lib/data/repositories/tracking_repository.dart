import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/order_models.dart';

class TrackingRepository {
  TrackingRepository(this._client);

  final ApiClient _client;

  Future<OrderTrackingModel> getOrderTracking(String orderId) {
    return _client.simulate(
      '/orders/$orderId/tracking',
      () => OrderTrackingModel.fromJson(dummyOrderTrackingJson),
    );
  }

  Future<void> cancelOrder(String orderId) {
    return _client.simulateMutation(
      '/orders/$orderId/cancel',
      {},
      () {},
    );
  }
}
