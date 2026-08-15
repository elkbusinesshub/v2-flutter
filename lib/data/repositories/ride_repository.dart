import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../features/seller/cubit/partner_cubit.dart';
import '../models/ride_models.dart';

/// The taxi/rides vertical against the backend (`/rides/*`).
///
/// Backend contract:
///  * `GET  /rides/types` → ride classes with fares and ETAs
///  * `GET  /rides/current-estimate` → static route estimate for the header
///  * `POST /rides/request` → the class's ETA (creates nothing)
///  * `POST /rides/bookings` → opens a search; whoever accepts first drives it
///  * `POST /rides/bookings/:id/{start,complete,cancel,rate}` → lifecycle
class RideRepository {
  RideRepository(this._client);

  final ApiClient _client;

  Future<List<RideTypeModel>> getRideTypes() async {
    final data = await _client.get(ApiEndpoints.rideTypes) as List;
    return data
        .map((e) => RideTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaxiLocationModel> getCurrentTrip() async {
    final data = await _client.get(ApiEndpoints.rideCurrentEstimate);
    return TaxiLocationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<DriverMatchModel> findDrivers(String rideTypeId) async {
    final data = await _client.post(
      ApiEndpoints.rideRequest,
      data: {'rideTypeId': rideTypeId},
    );
    return DriverMatchModel.fromJson(data as Map<String, dynamic>);
  }

  Future<RideBookingModel> createBooking({
    required String rideTypeId,
    required String pickupAddress,
    required String dropAddress,
    required String paymentMethod,
    double? pickupLat,
    double? pickupLng,
  }) async {
    final data = await _client.post(ApiEndpoints.rideBookings, data: {
      'rideTypeId': rideTypeId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'paymentMethod': paymentMethod,
      // Dispatch searches around this. Without it the backend has nowhere to
      // look and answers "no drivers" straight away rather than waiting.
      'pickupLat': ?pickupLat,
      'pickupLng': ?pickupLng,
    });
    return RideBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RideBookingModel>> getBookings() async {
    final data = await _client.get(ApiEndpoints.rideBookings) as List;
    return data
        .map((e) => RideBookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Rider confirms the pickup OTP with the driver.
  Future<RideBookingModel> startRide(String bookingId, String otpCode) async {
    final data = await _client.post(
      ApiEndpoints.rideStart(bookingId),
      data: {'otpCode': otpCode},
    );
    return RideBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<RideBookingModel> completeRide(String bookingId) async {
    final data = await _client.post(ApiEndpoints.rideComplete(bookingId));
    return RideBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancelRide(String bookingId) =>
      _client.post(ApiEndpoints.rideCancel(bookingId));

  /// Rates the driver (1–5) with an optional tip.
  Future<RideBookingModel> rateRide(
    String bookingId, {
    required int stars,
    int tip = 0,
  }) async {
    final data = await _client.post(
      ApiEndpoints.rideRate(bookingId),
      data: {'stars': stars, 'tip': tip},
    );
    return RideBookingModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── the partner's side ─────────────────────────────────────────────────

  /// Takes an offered trip. Fails with 409 when somebody accepted first.
  Future<void> acceptRide(String bookingId) async {
    await _client.post(ApiEndpoints.rideAccept(bookingId));
  }

  /// The trip this partner is driving, or null when they are free.
  Future<PartnerJob?> driverActiveTrip() async {
    final data = await _client.get(ApiEndpoints.rideDriverActive);
    if (data == null) return null;
    return PartnerJob.fromJson(data as Map<String, dynamic>);
  }

  /// Starts the trip with the code the rider shows — proof the driver is
  /// actually at the pickup.
  Future<void> driverStart(String bookingId, String otpCode) async {
    await _client.post(
      ApiEndpoints.rideDriverStart(bookingId),
      data: {'otpCode': otpCode},
    );
  }

  Future<void> driverComplete(String bookingId) async {
    await _client.post(ApiEndpoints.rideDriverComplete(bookingId));
  }
}
