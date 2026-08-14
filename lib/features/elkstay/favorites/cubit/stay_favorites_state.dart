part of 'stay_favorites_cubit.dart';

enum StayFavoritesStatus { initial, loading, success, error, guest }

class StayFavoritesState extends Equatable {
  const StayFavoritesState({
    this.status = StayFavoritesStatus.initial,
    this.stays = const [],
    this.errorMessage,
  });

  final StayFavoritesStatus status;
  final List<StayModel> stays;

  /// Carries both the load failure and a failed unsave, so the screen can
  /// surface either without a second field.
  final String? errorMessage;

  StayFavoritesState copyWith({
    StayFavoritesStatus? status,
    List<StayModel>? stays,
    String? errorMessage,
  }) =>
      StayFavoritesState(
        status: status ?? this.status,
        stays: stays ?? this.stays,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, stays, errorMessage];
}
