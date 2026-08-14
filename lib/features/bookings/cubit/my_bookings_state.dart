part of 'my_bookings_cubit.dart';

enum MyBookingsStatus { initial, loading, refreshing, loaded, guest, error }

/// Which statuses each tab shows. `pending` is kept because the UI offers the
/// label, but the backend only ever returns confirmed/completed/cancelled.
const _tabStatuses = {
  'upcoming': {'confirmed', 'pending'},
  'completed': {'completed'},
  'cancelled': {'cancelled'},
};

class MyBookingsState extends Equatable {
  const MyBookingsState({
    this.status = MyBookingsStatus.initial,
    this.bookings = const [],
    this.tab = 'upcoming',
    this.ratedIds = const {},
    this.cancellingId,
    this.errorMessage,
  });

  final MyBookingsStatus status;
  final List<BookingListItemModel> bookings;
  final String tab;

  /// Bookings rated during this session — see [MyBookingsCubit.markRated].
  final Set<String> ratedIds;
  final String? cancellingId;
  final String? errorMessage;

  List<BookingListItemModel> get visible => bookingsFor(tab);

  List<BookingListItemModel> bookingsFor(String tab) => bookings
      .where((b) => (_tabStatuses[tab] ?? const {}).contains(b.status))
      .toList();

  int countFor(String tab) => bookingsFor(tab).length;

  MyBookingsState copyWith({
    MyBookingsStatus? status,
    List<BookingListItemModel>? bookings,
    String? tab,
    Set<String>? ratedIds,
    String? cancellingId,
    String? errorMessage,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      tab: tab ?? this.tab,
      ratedIds: ratedIds ?? this.ratedIds,
      cancellingId: cancellingId ?? this.cancellingId,
      errorMessage: errorMessage,
    );
  }

  /// [copyWith] can't null a field, so ending a cancellation goes through here.
  MyBookingsState clearingCancellingId() => MyBookingsState(
        status: status,
        bookings: bookings,
        tab: tab,
        ratedIds: ratedIds,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, bookings, tab, ratedIds, cancellingId, errorMessage];
}
