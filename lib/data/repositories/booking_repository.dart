import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/booking_models.dart';

/// Service-slot bookings against the ELK backend.
///
/// Backend contract:
///  * `GET  /services/:id/booking-options` → dates, time slots, prefilled
///    address, pricing
///  * `POST /bookings { serviceId, day, time, address, lat?, lng? }` → confirmation
///    (the price is computed server-side)
///  * `GET  /bookings` → the user's bookings, newest first
///  * `POST /bookings/:id/cancel` → cancels a still-confirmed booking
class BookingRepository {
  BookingRepository(this._client);

  final ApiClient _client;

  Future<BookingDetailsModel> getBookingDetails(String serviceId) async {
    final data = await _client.get(ApiEndpoints.serviceBookingOptions(serviceId));
    return BookingDetailsModel.fromJson(data as Map<String, dynamic>);
  }

  /// Submits the booking and returns the confirmation payload.
  Future<BookingConfirmationModel> confirmBooking({
    required String serviceId,
    required int day,
    required String time,
    required String address,
    double? lat,
    double? lng,
  }) async {
    final data = await _client.post(ApiEndpoints.bookings, data: {
      'serviceId': serviceId,
      'day': day,
      'time': time,
      'address': address,
      // Omitted for a hand-typed address: the backend takes them as optional
      // and the tracking screen simply shows no map without them.
      'lat': ?lat,
      'lng': ?lng,
    });
    return BookingConfirmationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<BookingListItemModel>> getBookings() async {
    final data = await _client.get(ApiEndpoints.bookings);
    return (data as List)
        .map((e) => BookingListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cancels [bookingId], routed by the vertical that owns it.
  ///
  /// "My Bookings" lists every vertical, but there is no single cancel
  /// endpoint — each one enforces its own rules (ElkClean's 2-hour cutoff,
  /// the rental's pickup window, and so on), so the caller must say which
  /// table the booking came from.
  Future<void> cancelBooking(String bookingId, {String vertical = 'services'}) async {
    // An order against a listing cancels by moving to CANCELLED, not by a
    // dedicated endpoint — and the backend refuses the move once the seller
    // has started work.
    if (vertical == 'marketplace') {
      await _client.patch(
        ApiEndpoints.marketplaceOrderStatus(bookingId),
        data: {'status': 'CANCELLED'},
      );
      return;
    }
    await _client.post(switch (vertical) {
      'elkclean' => ApiEndpoints.elkCleanCancelBooking(bookingId),
      'elkrep' => ApiEndpoints.elkRepCancelBooking(bookingId),
      'rentals' => ApiEndpoints.rentalCancelBooking(bookingId),
      'porter' => ApiEndpoints.porterCancel(bookingId),
      'rides' => ApiEndpoints.rideCancel(bookingId),
      'elkstay' => ApiEndpoints.elkStayCancelBooking(bookingId),
      _ => ApiEndpoints.cancelBooking(bookingId),
    });
  }
}
