import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/elkrep_models.dart';

/// The ELK Repair vertical against the backend (`/elkrep/*`).
///
/// Backend contract:
///  * `GET  /elkrep/home` → greeting, trade grid, offers
///  * `GET  /elkrep/categories/:slug/services` → active services
///  * `GET  /elkrep/booking-options` → date strip, arrival windows,
///    visit fee, saved addresses
///  * `POST /elkrep/bookings` → server-priced booking (mock payment)
class ElkRepRepository {
  ElkRepRepository(this._client);

  final ApiClient _client;

  Future<RepairHomeFeedModel> getHomeFeed() async {
    final data = await _client.get(ApiEndpoints.elkRepHome);
    return RepairHomeFeedModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RepairServiceModel>> getCategoryServices(String slug) async {
    final data = await _client.get(ApiEndpoints.elkRepCategoryServices(slug)) as List;
    return data
        .map((e) => RepairServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RepairBookingOptionsModel> getBookingOptions() async {
    final data = await _client.get(ApiEndpoints.elkRepBookingOptions);
    return RepairBookingOptionsModel.fromJson(data as Map<String, dynamic>);
  }

  /// Books the cart. [scheduledDate] is `YYYY-MM-DD` from the offered date
  /// strip; [addressId] is a saved `/locations` address. The backend prices
  /// the cart itself.
  Future<RepairBookingModel> createBooking({
    required List<RepairCartLine> items,
    required String scheduledDate,
    required String timeSlot,
    required String addressId,
    required String paymentMethod,
    String? promoCode,
  }) async {
    final data = await _client.post(ApiEndpoints.elkRepBookings, data: {
      'items': [
        for (final line in items)
          {'serviceId': line.service.id, 'quantity': line.quantity},
      ],
      'scheduledDate': scheduledDate,
      'timeSlot': timeSlot,
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'promoCode': ?promoCode,
    });
    return RepairBookingModel.fromJson(data as Map<String, dynamic>);
  }
}
