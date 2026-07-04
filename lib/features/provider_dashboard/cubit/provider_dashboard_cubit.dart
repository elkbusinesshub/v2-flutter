import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_dashboard_state.dart';

class ProviderDashboardCubit extends Cubit<ProviderDashboardState> {
  ProviderDashboardCubit(this._repository) : super(const ProviderDashboardState());

  final ProviderRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: ProviderDashboardStatus.loading));
    try {
      final dashboard = await _repository.getDashboard();
      emit(state.copyWith(status: ProviderDashboardStatus.loaded, dashboard: dashboard));
    } catch (e) {
      emit(state.copyWith(status: ProviderDashboardStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> toggleAvailability() async {
    final dashboard = state.dashboard;
    if (dashboard == null) return;
    final newValue = !dashboard.isAvailable;
    await _repository.setAvailability(newValue);
    emit(state.copyWith(
      dashboard: ProviderDashboardModel(
        businessName: dashboard.businessName,
        modeLabel: dashboard.modeLabel,
        isAvailable: newValue,
        stats: dashboard.stats,
        requests: dashboard.requests,
      ),
    ));
  }

  Future<void> respondToRequest(ProviderRequestModel request, {required bool accept}) async {
    final dashboard = state.dashboard;
    if (dashboard == null) return;

    emit(state.copyWith(respondingRequestId: request.id));
    try {
      final updated = await _repository.respondToRequest(request: request, accept: accept);
      emit(state.copyWith(
        clearRespondingRequestId: true,
        dashboard: ProviderDashboardModel(
          businessName: dashboard.businessName,
          modeLabel: dashboard.modeLabel,
          isAvailable: dashboard.isAvailable,
          stats: dashboard.stats,
          requests: [
            for (final r in dashboard.requests) if (r.id == updated.id) updated else r,
          ],
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        clearRespondingRequestId: true,
        status: ProviderDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
