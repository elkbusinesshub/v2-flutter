import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/booking_models.dart';

/// The "My Bookings" list, across every system that still holds one.
///
/// Backend contract:
///  * `GET  /bookings` → the user's bookings, newest first — porter jobs,
///    rides, and orders placed against a seller's listing
///  * cancelling is routed per vertical; see [cancelBooking]
class BookingRepository {
  BookingRepository(this._client);

  final ApiClient _client;

  Future<List<BookingListItemModel>> getBookings() async {
    final data = await _client.get(ApiEndpoints.bookings);
    return (data as List)
        .map((e) => BookingListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cancels [bookingId], routed by the vertical that owns it.
  ///
  /// "My Bookings" lists three sources and there is no single cancel endpoint —
  /// porter and rides each enforce their own rules, so the caller must say
  /// which one the booking came from. Anything else is an order against a
  /// listing.
  Future<void> cancelBooking(String bookingId, {String vertical = 'marketplace'}) async {
    switch (vertical) {
      case 'porter':
        await _client.post(ApiEndpoints.porterCancel(bookingId));
      case 'rides':
        await _client.post(ApiEndpoints.rideCancel(bookingId));
      default:
        // An order against a listing cancels by moving to CANCELLED, not by a
        // dedicated endpoint — and the backend refuses the move once the
        // seller has started work.
        await _client.patch(
          ApiEndpoints.marketplaceOrderStatus(bookingId),
          data: {'status': 'CANCELLED'},
        );
    }
  }
}
