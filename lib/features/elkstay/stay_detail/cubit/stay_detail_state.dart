part of 'stay_detail_cubit.dart';

enum StayDetailStatus { initial, loading, success, error, guest }

class StayDetailState extends Equatable {
  const StayDetailState({
    this.status = StayDetailStatus.initial,
    this.stay,
    this.isSaved = false,
    this.roomOptions = const [],
    this.selectedRoomOptionId,
    this.isSubmitting = false,
    this.lastBooking,
    this.actionError,
    this.errorMessage,
  });

  final StayDetailStatus status;
  final StayModel? stay;
  final bool isSaved;
  final List<StayRoomOption> roomOptions;
  final String? selectedRoomOptionId;

  /// True while a booking or visit request is in flight.
  final bool isSubmitting;

  /// The booking/visit created by the last successful request.
  final StayBookingModel? lastBooking;

  /// Failure from save/book/visit (the detail itself stays on screen).
  final String? actionError;
  final String? errorMessage;

  StayRoomOption? get selectedRoomOption =>
      roomOptions.where((r) => r.id == selectedRoomOptionId).firstOrNull;

  StayDetailState copyWith({
    StayDetailStatus? status,
    StayModel? stay,
    bool? isSaved,
    List<StayRoomOption>? roomOptions,
    String? selectedRoomOptionId,
    bool? isSubmitting,
    StayBookingModel? lastBooking,
    String? actionError,
    String? errorMessage,
  }) =>
      StayDetailState(
        status: status ?? this.status,
        stay: stay ?? this.stay,
        isSaved: isSaved ?? this.isSaved,
        roomOptions: roomOptions ?? this.roomOptions,
        selectedRoomOptionId: selectedRoomOptionId ?? this.selectedRoomOptionId,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        lastBooking: lastBooking ?? this.lastBooking,
        actionError: actionError,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        stay,
        isSaved,
        roomOptions,
        selectedRoomOptionId,
        isSubmitting,
        lastBooking,
        actionError,
        errorMessage,
      ];
}
