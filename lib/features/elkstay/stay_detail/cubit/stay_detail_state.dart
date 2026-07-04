part of 'stay_detail_cubit.dart';

enum StayDetailStatus { initial, loading, success, error }

class StayDetailState extends Equatable {
  const StayDetailState({
    this.status = StayDetailStatus.initial,
    this.stay,
    this.isSaved = false,
    this.errorMessage,
  });

  final StayDetailStatus status;
  final StayModel? stay;
  final bool isSaved;
  final String? errorMessage;

  StayDetailState copyWith({
    StayDetailStatus? status,
    StayModel? stay,
    bool? isSaved,
    String? errorMessage,
  }) =>
      StayDetailState(
        status: status ?? this.status,
        stay: stay ?? this.stay,
        isSaved: isSaved ?? this.isSaved,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, stay, isSaved, errorMessage];
}
