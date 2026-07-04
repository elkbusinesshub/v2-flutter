import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/booking_models.dart';

class BookingRepository {
  BookingRepository(this._client);

  final ApiClient _client;

  Future<BookingDetailsModel> getBookingDetails(String serviceId) {
    return _client.simulate(
      '/services/$serviceId/booking-options',
      () => BookingDetailsModel.fromJson(dummyBookingDetailsJson),
    );
  }

  /// Submits the booking and returns a confirmation payload.
  Future<BookingConfirmationModel> confirmBooking({
    required String serviceId,
    required String serviceName,
    required int selectedDay,
    required String selectedWeekday,
    required String selectedTime,
    required String address,
    required double total,
  }) {
    return _client.simulateMutation(
      '/bookings',
      {
        'serviceId': serviceId,
        'day': selectedDay,
        'time': selectedTime,
        'address': address,
        'total': total,
      },
      () => BookingConfirmationModel(
        bookingReference: '#ELK-2025-04921',
        serviceName: serviceName,
        dateTimeLabel: '$selectedWeekday $selectedDay, $selectedTime',
        providerName: 'Royal Shine ✓',
        amountPaid: total,
      ),
      delay: const Duration(milliseconds: 900),
    );
  }
}
