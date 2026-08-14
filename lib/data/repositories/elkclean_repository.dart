import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/elkclean_models.dart';

/// The ELK Clean vertical against the backend (`/elkclean/*`).
///
/// Backend contract:
///  * `GET  /elkclean/home` → greeting, category grid, offers
///  * `GET  /elkclean/categories/:slug/services` → active services
///  * `GET  /elkclean/booking-options` → date strip, arrival windows,
///    supply fee, saved addresses
///  * `POST /elkclean/bookings` → server-priced booking (mock payment)
class ElkCleanRepository {
  ElkCleanRepository(this._client);

  final ApiClient _client;

  Future<CleanHomeFeedModel> getHomeFeed() async {
    final data = await _client.get(ApiEndpoints.elkCleanHome);
    return CleanHomeFeedModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CleanServiceModel>> getCategoryServices(String slug) async {
    final data = await _client.get(ApiEndpoints.elkCleanCategoryServices(slug)) as List;
    return data
        .map((e) => CleanServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CleanBookingOptionsModel> getBookingOptions() async {
    final data = await _client.get(ApiEndpoints.elkCleanBookingOptions);
    return CleanBookingOptionsModel.fromJson(data as Map<String, dynamic>);
  }

  /// Books the cart. [scheduledDate] is `YYYY-MM-DD` from the offered date
  /// strip; [addressId] is a saved `/locations` address. The backend prices
  /// the cart itself.
  Future<CleanBookingModel> createBooking({
    required List<CleanCartLine> items,
    required String scheduledDate,
    required String timeSlot,
    required String addressId,
    required String paymentMethod,
    String? promoCode,
  }) async {
    final data = await _client.post(ApiEndpoints.elkCleanBookings, data: {
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
    return CleanBookingModel.fromJson(data as Map<String, dynamic>);
  }
}
