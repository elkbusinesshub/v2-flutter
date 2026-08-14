import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/stay_models.dart';

/// The ELK Stay vertical against the backend (`/elkstay/*`).
///
/// Backend contract:
///  * `GET    /elkstay/home` → greeting, category cards (live counts), top rated
///  * `GET    /elkstay/stays?category&verified&maxPrice&roomType&meals&search`
///  * `GET    /elkstay/stay/:id` → listing + `isSaved` + `roomOptions`
///  * `POST`/`DELETE /elkstay/stay/:id/favorite` → save / unsave
///  * `GET    /elkstay/bookings` → stay bookings and visit requests
///  * `POST   /elkstay/bookings` → booking (priced server-side)
///  * `POST   /elkstay/visits` → schedule a property visit
class ElkStayRepository {
  ElkStayRepository(this._client);

  final ApiClient _client;

  Future<ElkStayHomeFeed> fetchHomeData() async {
    final data = await _client.get(ApiEndpoints.elkStayHome) as Map<String, dynamic>;
    return ElkStayHomeFeed(
      userName: data['userName'] as String,
      location: data['location'] as String,
      categories: (data['categories'] as List)
          .map((e) => StayCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topRated: (data['topRated'] as List)
          .map((e) => StayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Listings with the explore screen's filter chips applied server-side.
  Future<List<StayModel>> fetchStays({
    StayCategoryType? filter,
    bool? verifiedOnly,
    int? maxPrice,
    String? roomType,
    bool? meals,
    String? search,
  }) async {
    final data = await _client.get(ApiEndpoints.elkStays, queryParameters: {
      'category': ?filter?.id,
      if (verifiedOnly == true) 'verified': true,
      'maxPrice': ?maxPrice,
      'roomType': ?roomType,
      if (meals == true) 'meals': true,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    }) as List;
    return data
        .map((e) => StayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StayDetailModel> fetchStayDetail(String stayId) async {
    final data = await _client.get(ApiEndpoints.elkStayDetail(stayId));
    return StayDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> saveStay(String stayId) =>
      _client.post(ApiEndpoints.elkStayFavorite(stayId));

  Future<void> unsaveStay(String stayId) =>
      _client.delete(ApiEndpoints.elkStayFavorite(stayId));

  Future<List<StayModel>> fetchFavorites() async {
    final data = await _client.get(ApiEndpoints.elkStayFavorites) as List;
    return data
        .map((e) => StayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StayBookingModel>> fetchBookings() async {
    final data = await _client.get(ApiEndpoints.elkStayBookings) as List;
    return data
        .map((e) => StayBookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Requests a booking. The backend prices it
  /// (first month + deposit + service fee − coupon).
  Future<StayBookingModel> createBooking({
    required String stayId,
    required String roomOptionId,
    required String moveInDate,
    required int durationMonths,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final data = await _client.post(ApiEndpoints.elkStayBookings, data: {
      'stayId': stayId,
      'roomOptionId': roomOptionId,
      'moveInDate': moveInDate,
      'durationMonths': durationMonths,
      'paymentMethod': paymentMethod,
      'couponCode': ?couponCode,
    });
    return StayBookingModel.fromJson(data as Map<String, dynamic>);
  }

  /// Schedules a property visit. [visitAt] is an ISO-8601 instant.
  Future<StayBookingModel> scheduleVisit({
    required String stayId,
    required String visitAt,
  }) async {
    final data = await _client.post(ApiEndpoints.elkStayVisits, data: {
      'stayId': stayId,
      'visitAt': visitAt,
    });
    return StayBookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancelBooking(String bookingId) =>
      _client.post(ApiEndpoints.elkStayCancelBooking(bookingId));
}
