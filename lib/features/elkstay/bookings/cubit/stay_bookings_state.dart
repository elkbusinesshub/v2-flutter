part of 'stay_bookings_cubit.dart';

enum StayBookingsStatus { initial, loading, success, error }

class StayBookingsState extends Equatable {
  const StayBookingsState({
    this.status = StayBookingsStatus.initial,
    this.bookings = const [],
    this.activeTab = 0,
    this.errorMessage,
  });

  final StayBookingsStatus status;
  final List<StayBookingModel> bookings;
  final int activeTab;
  final String? errorMessage;

  List<StayBookingModel> get visibleBookings => switch (activeTab) {
        1 => bookings.where((b) => b.status == StayBookingStatus.visitBooked || b.status == StayBookingStatus.pending).toList(),
        2 => bookings.where((b) => b.status == StayBookingStatus.past).toList(),
        _ => bookings.where((b) => b.status == StayBookingStatus.confirmed).toList(),
      };

  StayBookingsState copyWith({
    StayBookingsStatus? status,
    List<StayBookingModel>? bookings,
    int? activeTab,
    String? errorMessage,
  }) =>
      StayBookingsState(
        status: status ?? this.status,
        bookings: bookings ?? this.bookings,
        activeTab: activeTab ?? this.activeTab,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, bookings, activeTab, errorMessage];
}
