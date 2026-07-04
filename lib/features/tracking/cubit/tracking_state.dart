part of 'tracking_cubit.dart';

enum TrackingStatus { initial, loading, loaded, error }

class TrackingState extends Equatable {
  const TrackingState({
    this.status = TrackingStatus.initial,
    this.tracking,
    this.isCancelling = false,
    this.errorMessage,
  });

  final TrackingStatus status;
  final OrderTrackingModel? tracking;
  final bool isCancelling;
  final String? errorMessage;

  TrackingState copyWith({
    TrackingStatus? status,
    OrderTrackingModel? tracking,
    bool? isCancelling,
    String? errorMessage,
  }) {
    return TrackingState(
      status: status ?? this.status,
      tracking: tracking ?? this.tracking,
      isCancelling: isCancelling ?? this.isCancelling,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tracking, isCancelling, errorMessage];
}
