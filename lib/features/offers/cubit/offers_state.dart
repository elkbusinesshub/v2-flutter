part of 'offers_cubit.dart';

enum OffersStatus { initial, loading, loaded, error }

class OffersState extends Equatable {
  const OffersState({
    this.status = OffersStatus.initial,
    this.page,
    this.errorMessage,
  });

  final OffersStatus status;
  final OffersPageModel? page;
  final String? errorMessage;

  OffersState copyWith({
    OffersStatus? status,
    OffersPageModel? page,
    String? errorMessage,
  }) {
    return OffersState(
      status: status ?? this.status,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, page, errorMessage];
}
