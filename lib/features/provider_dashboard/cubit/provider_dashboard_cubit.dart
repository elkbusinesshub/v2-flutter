import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_dashboard_state.dart';

class ProviderDashboardCubit extends Cubit<ProviderDashboardState> {
  ProviderDashboardCubit(this._repository, this._preferences)
      : super(const ProviderDashboardState());

  final ProviderRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadDashboard() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ProviderDashboardStatus.guest));
      return;
    }
    emit(state.copyWith(status: ProviderDashboardStatus.loading));
    try {
      final dashboard = await _repository.getDashboard();
      emit(state.copyWith(
        status: ProviderDashboardStatus.loaded,
        dashboard: dashboard,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: isProviderNotRegistered(e)
            ? ProviderDashboardStatus.notRegistered
            : ProviderDashboardStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// The server is the source of truth for the new flag — a failed toggle must
  /// not leave the switch showing a state the backend never accepted.
  Future<String?> toggleAvailability() async {
    final dashboard = state.dashboard;
    if (dashboard == null) return null;
    try {
      final isAvailable = await _repository.setAvailability(!dashboard.isAvailable);
      emit(state.copyWith(dashboard: _withAvailability(dashboard, isAvailable)));
      return null;
    } catch (e) {
      return friendlyErrorMessage(e);
    }
  }

  /// Returns an error message, or `null` when the response was recorded.
  Future<String?> respondToRequest(
    ProviderRequestModel request, {
    required bool accept,
  }) async {
    final dashboard = state.dashboard;
    if (dashboard == null) return null;

    emit(state.copyWith(respondingRequestId: request.id));
    try {
      final updated = await _repository.respondToRequest(request: request, accept: accept);
      emit(state.copyWith(
        clearRespondingRequestId: true,
        dashboard: _withRequests(dashboard, [
          for (final r in dashboard.requests) if (r.id == updated.id) updated else r,
        ]),
      ));
      return null;
    } catch (e) {
      // Keep the dashboard on screen — only this request failed. A 409 here
      // means it was already handled, so the message is what matters.
      emit(state.copyWith(clearRespondingRequestId: true));
      return friendlyErrorMessage(e);
    }
  }

  ProviderDashboardModel _withAvailability(ProviderDashboardModel d, bool isAvailable) =>
      ProviderDashboardModel(
        businessName: d.businessName,
        modeLabel: d.modeLabel,
        isAvailable: isAvailable,
        stats: d.stats,
        requests: d.requests,
      );

  ProviderDashboardModel _withRequests(
    ProviderDashboardModel d,
    List<ProviderRequestModel> requests,
  ) =>
      ProviderDashboardModel(
        businessName: d.businessName,
        modeLabel: d.modeLabel,
        isAvailable: d.isAvailable,
        stats: d.stats,
        requests: requests,
      );
}
