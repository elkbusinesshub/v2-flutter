part of 'provider_schedule_cubit.dart';

enum ProviderScheduleStatus { initial, loading, loaded, error }

class ProviderScheduleState extends Equatable {
  const ProviderScheduleState({
    this.status = ProviderScheduleStatus.initial,
    this.schedule,
    this.errorMessage,
  });

  final ProviderScheduleStatus status;
  final ProviderScheduleModel? schedule;
  final String? errorMessage;

  ProviderScheduleState copyWith({
    ProviderScheduleStatus? status,
    ProviderScheduleModel? schedule,
    String? errorMessage,
  }) {
    return ProviderScheduleState(
      status: status ?? this.status,
      schedule: schedule ?? this.schedule,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, schedule, errorMessage];
}
