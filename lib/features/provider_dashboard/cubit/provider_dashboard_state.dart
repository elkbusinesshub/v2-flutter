part of 'provider_dashboard_cubit.dart';

enum ProviderDashboardStatus { initial, loading, loaded, error }

class ProviderDashboardState extends Equatable {
  const ProviderDashboardState({
    this.status = ProviderDashboardStatus.initial,
    this.dashboard,
    this.respondingRequestId,
    this.errorMessage,
  });

  final ProviderDashboardStatus status;
  final ProviderDashboardModel? dashboard;
  final String? respondingRequestId;
  final String? errorMessage;

  ProviderDashboardState copyWith({
    ProviderDashboardStatus? status,
    ProviderDashboardModel? dashboard,
    String? respondingRequestId,
    bool clearRespondingRequestId = false,
    String? errorMessage,
  }) {
    return ProviderDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      respondingRequestId:
          clearRespondingRequestId ? null : respondingRequestId ?? this.respondingRequestId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, respondingRequestId, errorMessage];
}
