import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/order_models.dart';

/// Order tracking. An "order" is a home-services booking, addressed by its
/// booking **id** (not its `ELK-YYYY-NNNNN` reference).
///
/// Backend contract:
///  * `GET  /orders/:id/tracking` → status label + the five-step timeline
///  * `POST /orders/:id/cancel` → cancels a still-confirmed order
///
/// The timeline is derived from `Booking.status`; there is no separate
/// tracking state machine, so the steps only move when the status does.
class TrackingRepository {
  TrackingRepository(this._client);

  final ApiClient _client;

  Future<OrderTrackingModel> getOrderTracking(String orderId) async {
    final data = await _client.get(ApiEndpoints.orderTracking(orderId));
    return OrderTrackingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancelOrder(String orderId) async {
    await _client.post(ApiEndpoints.orderCancel(orderId));
  }
}
