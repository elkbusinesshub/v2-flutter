import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/rental_models.dart';

/// The car-rental vertical against the backend (`/rentals/*`).
///
/// Backend contract:
///  * `GET  /rentals/cars?category&period&sort` → catalog with pagination meta
///  * `GET  /rentals/branches` → self-pickup branches
///  * `GET  /rentals/extras` → add-ons priced per day
///  * `POST /rentals/quote` → server-side price breakdown (no side effects)
///  * `POST /rentals/bookings` → booking (availability-checked, mock payment)
///  * `GET  /rentals/bookings` → my rental history
class RentalRepository {
  RentalRepository(this._client);

  final ApiClient _client;

  Future<List<RentalCarModel>> getCars({
    RentalPeriod period = RentalPeriod.daily,
    String typeFilter = 'All',
  }) async {
    final category = typeFilter.toLowerCase();
    final data = await _client.get(ApiEndpoints.rentalCars, queryParameters: {
      if (category != 'all') 'category': category,
      'period': period.id,
      'sort': 'price',
    }) as List;
    return data
        .map((e) => RentalCarModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RentalBranchModel>> getBranches() async {
    final data = await _client.get(ApiEndpoints.rentalBranches) as List;
    return data
        .map((e) => RentalBranchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RentalExtraModel>> getExtras() async {
    final data = await _client.get(ApiEndpoints.rentalExtras) as List;
    return data
        .map((e) => RentalExtraModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Prices a rental without booking it — used by the review step and to
  /// validate promo codes server-side.
  Future<RentalQuoteModel> quote(Map<String, dynamic> request) async {
    final data = await _client.post(ApiEndpoints.rentalQuote, data: request);
    return RentalQuoteModel.fromJson(data as Map<String, dynamic>);
  }

  /// Creates the booking. [request] is the quote payload plus
  /// `paymentMethod` and `agreedToTerms`.
  Future<RentalBookingModel> createBooking(Map<String, dynamic> request) async {
    final data = await _client.post(ApiEndpoints.rentalBookings, data: request);
    return RentalBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RentalBookingModel>> getBookings() async {
    final data = await _client.get(ApiEndpoints.rentalBookings) as List;
    return data
        .map((e) => RentalBookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
