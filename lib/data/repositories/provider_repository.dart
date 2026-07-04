import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/provider_models.dart';

class ProviderRepository {
  ProviderRepository(this._client);

  final ApiClient _client;

  Future<ProviderDashboardModel> getDashboard() {
    return _client.simulate(
      '/provider/dashboard',
      () => ProviderDashboardModel.fromJson(dummyProviderProfileJson),
    );
  }

  Future<void> setAvailability(bool isAvailable) {
    return _client.simulateMutation(
      '/provider/availability',
      {'isAvailable': isAvailable},
      () {},
    );
  }

  /// Accepts or declines a booking request, returning the updated request.
  Future<ProviderRequestModel> respondToRequest({
    required ProviderRequestModel request,
    required bool accept,
  }) {
    return _client.simulateMutation(
      '/provider/requests/${request.id}/respond',
      {'accept': accept},
      () => request.copyWith(
        status: accept
            ? ProviderRequestStatus.accepted
            : ProviderRequestStatus.declined,
      ),
      delay: const Duration(milliseconds: 500),
    );
  }

  Future<ProviderScheduleModel> getSchedule() {
    return _client.simulate(
      '/provider/schedule',
      () => ProviderScheduleModel.fromJson(dummyProviderScheduleJson),
    );
  }

  Future<EarningsSummaryModel> getEarnings() {
    return _client.simulate(
      '/provider/earnings',
      () => EarningsSummaryModel.fromJson(dummyEarningsJson),
    );
  }

  Future<void> submitRegistration(ProviderRegistrationModel registration) {
    return _client.simulateMutation(
      '/provider/registration',
      registration.toJson(),
      () {},
      delay: const Duration(milliseconds: 900),
    );
  }
}
