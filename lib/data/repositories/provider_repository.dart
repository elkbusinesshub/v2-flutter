import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/errors/api_exception.dart';
import '../models/provider_models.dart';

/// `403` on a provider endpoint means one thing only — the caller has no
/// provider profile yet (`assertProfile` in `provider.service.ts`). The cubits
/// use this to prompt registration rather than showing a permissions error.
bool isProviderNotRegistered(Object error) =>
    error is ApiException && error.type == ApiErrorType.forbidden;

/// The provider persona — registration, dashboard, schedule and earnings.
///
/// Backend contract:
///  * `POST /provider/registration` → submits an application (`409` if one
///    already exists)
///  * `GET  /provider/dashboard | /provider/schedule | /provider/earnings`
///  * `POST /provider/availability { isAvailable }` → `{ isAvailable }`
///  * `POST /provider/requests/:id/respond { accept }` → the updated request
///
/// **Every read requires a provider profile.** Without one the backend
/// returns `403 No provider profile — register first`, which the cubits turn
/// into a "register first" state rather than an error.
class ProviderRepository {
  ProviderRepository(this._client);

  final ApiClient _client;

  Future<ProviderDashboardModel> getDashboard() async {
    final data = await _client.get(ApiEndpoints.providerDashboard);
    return ProviderDashboardModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> setAvailability(bool isAvailable) async {
    final data = await _client.post(
      ApiEndpoints.providerAvailability,
      data: {'isAvailable': isAvailable},
    );
    return (data as Map<String, dynamic>)['isAvailable'] as bool;
  }

  /// Accepts or declines a booking request, returning the updated request.
  Future<ProviderRequestModel> respondToRequest({
    required ProviderRequestModel request,
    required bool accept,
  }) async {
    final data = await _client.post(
      ApiEndpoints.providerRespondRequest(request.id),
      data: {'accept': accept},
    );
    return ProviderRequestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ProviderScheduleModel> getSchedule() async {
    final data = await _client.get(ApiEndpoints.providerSchedule);
    return ProviderScheduleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<EarningsSummaryModel> getEarnings() async {
    final data = await _client.get(ApiEndpoints.providerEarnings);
    return EarningsSummaryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> submitRegistration(ProviderRegistrationModel registration) async {
    await _client.post(
      ApiEndpoints.providerRegistration,
      data: registration.toJson(),
    );
  }
}
