import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/seller/cubit/partner_cubit.dart';
import '../models/porter_models.dart';

/// The porter/delivery vertical against the backend (`/porter/*`).
///
/// Backend contract:
///  * `GET  /porter/options` → vehicles, add-ons, pickup windows, fees, route
///  * `POST /porter/quote` → server-side fare breakdown (no side effects)
///  * `POST /porter/bookings` → delivery (now or scheduled, mock payment)
///  * `GET  /porter/bookings` → my deliveries
class PorterRepository {
  PorterRepository(this._client);

  final ApiClient _client;

  Future<PorterPageModel> getPorterOptions() async {
    final data = await _client.get(ApiEndpoints.porterOptions);
    return PorterPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PorterBreakdown> quote({
    required String vehicleId,
    List<String> addons = const [],
  }) async {
    final data = await _client.post(ApiEndpoints.porterQuote, data: {
      'vehicleId': vehicleId,
      'addons': addons,
    });
    final json = data as Map<String, dynamic>;
    return PorterBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>);
  }

  /// Books the delivery. Omit [scheduledDate] and [pickupWindow] for
  /// "pick up now".
  Future<PorterBookingModel> createBooking({
    required String vehicleId,
    required String pickupAddress,
    required String dropAddress,
    required String paymentMethod,
    List<String> addons = const [],
    String? packageType,
    String? weightLabel,
    String? scheduledDate,
    String? pickupWindow,
  }) async {
    final data = await _client.post(ApiEndpoints.porterBookings, data: {
      'vehicleId': vehicleId,
      'addons': addons,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'paymentMethod': paymentMethod,
      'packageType': ?packageType,
      'weightLabel': ?weightLabel,
      'scheduledDate': ?scheduledDate,
      'pickupWindow': ?pickupWindow,
    });
    return PorterBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PorterBookingModel>> getBookings() async {
    final data = await _client.get(ApiEndpoints.porterBookings) as List;
    return data
        .map((e) => PorterBookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelBooking(String bookingId) =>
      _client.post(ApiEndpoints.porterCancel(bookingId));

  // ─── the partner's side ─────────────────────────────────────────────────

  /// Takes an offered delivery. Fails with 409 when somebody accepted first.
  Future<void> acceptJob(String bookingId) async {
    await _client.post(ApiEndpoints.porterAccept(bookingId));
  }

  /// The delivery this partner is running, or null when they are free.
  Future<PartnerJob?> driverActiveJob() async {
    final data = await _client.get(ApiEndpoints.porterDriverActive);
    if (data == null) return null;
    return PartnerJob.fromJson(data as Map<String, dynamic>);
  }

  /// Collects the parcel against the code the sender shows.
  Future<void> driverPickUp(String bookingId, String otpCode) async {
    await _client.post(
      ApiEndpoints.porterDriverPickup(bookingId),
      data: {'otpCode': otpCode},
    );
  }

  Future<void> driverDeliver(String bookingId) async {
    await _client.post(ApiEndpoints.porterDriverDeliver(bookingId));
  }
}
