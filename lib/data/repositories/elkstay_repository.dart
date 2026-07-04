import '../datasources/api_client.dart';
import '../datasources/elkstay_dummy_data.dart';
import '../models/stay_models.dart';

class ElkStayRepository {
  ElkStayRepository(this._client);

  final ApiClient _client;

  Future<ElkStayHomeFeed> fetchHomeData() => _client.simulate(
        '/elkstay/home',
        () => ElkStayHomeFeed(
          userName: 'Aarav',
          location: 'Koramangala, Bangalore',
          categories: elkStayCategoriesJson
              .map(StayCategoryModel.fromJson)
              .toList(),
          topRated: elkStayStaysJson
              .take(4)
              .map(StayModel.fromJson)
              .toList(),
        ),
      );

  Future<List<StayModel>> fetchStays({StayCategoryType? filter}) =>
      _client.simulate(
        '/elkstay/stays',
        () {
          final all = elkStayStaysJson.map(StayModel.fromJson).toList();
          if (filter == null) return all;
          return all.where((s) => s.categoryType == filter).toList();
        },
      );

  Future<StayModel> fetchStayDetail(String stayId) =>
      _client.simulate('/elkstay/stay/$stayId', () {
        final json = elkStayStaysJson.firstWhere(
          (s) => s['id'] == stayId,
          orElse: () => elkStayStaysJson.first,
        );
        return StayModel.fromJson(json);
      });

  Future<List<StayBookingModel>> fetchBookings() => _client.simulate(
        '/elkstay/bookings',
        () => elkStayBookingsJson.map(StayBookingModel.fromJson).toList(),
      );
}
