part of 'services_cubit.dart';

enum ServicesStatus { initial, loading, loaded, error }

class ServicesState extends Equatable {
  const ServicesState({
    this.status = ServicesStatus.initial,
    this.groups = const [],
    this.errorMessage,
  });

  final ServicesStatus status;
  final List<ServiceGroupModel> groups;
  final String? errorMessage;

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceGroupModel>? groups,
    String? errorMessage,
  }) {
    return ServicesState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, groups, errorMessage];
}
