part of 'service_detail_cubit.dart';

enum ServiceDetailStatus { initial, loading, loaded, error }

class ServiceDetailState extends Equatable {
  const ServiceDetailState({
    this.status = ServiceDetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  final ServiceDetailStatus status;
  final ServiceDetailModel? detail;
  final String? errorMessage;

  ServiceDetailState copyWith({
    ServiceDetailStatus? status,
    ServiceDetailModel? detail,
    String? errorMessage,
  }) {
    return ServiceDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
