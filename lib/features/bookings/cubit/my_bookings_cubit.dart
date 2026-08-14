import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/booking_models.dart';
import '../../../data/repositories/booking_repository.dart';

part 'my_bookings_state.dart';

/// Backs the My Bookings tab: the list, its status tabs and cancellation.
class MyBookingsCubit extends Cubit<MyBookingsState> {
  MyBookingsCubit(this._repository, this._preferences)
      : super(const MyBookingsState());

  final BookingRepository _repository;
  final AppPreferences _preferences;

  Future<void> load({bool refresh = false}) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: MyBookingsStatus.guest));
      return;
    }
    emit(state.copyWith(
      status: refresh ? MyBookingsStatus.refreshing : MyBookingsStatus.loading,
    ));
    try {
      final bookings = await _repository.getBookings();
      emit(state.copyWith(status: MyBookingsStatus.loaded, bookings: bookings));
    } catch (e) {
      emit(state.copyWith(
        status: MyBookingsStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void selectTab(String tab) => emit(state.copyWith(tab: tab));

  /// Cancels, then reloads so the list reflects the server's new status
  /// rather than a locally guessed one. Returns the message to show.
  Future<String> cancelBooking(String bookingId) async {
    emit(state.copyWith(cancellingId: bookingId));
    try {
      // Route to the vertical that owns it — there is no shared cancel.
      final booking =
          state.bookings.where((b) => b.id == bookingId).firstOrNull;
      await _repository.cancelBooking(
        bookingId,
        vertical: booking?.vertical ?? 'services',
      );
      await load(refresh: true);
      emit(state.clearingCancellingId());
      return L10n.current.bookingCancelledToast;
    } catch (e) {
      emit(state.clearingCancellingId());
      return friendlyErrorMessage(e);
    }
  }

  /// The list has no `hasReview` flag, so a rating is remembered for this
  /// session once submitted; a reopened app relies on the server's
  /// `ALREADY_REVIEWED` response instead.
  void markRated(String bookingId) {
    emit(state.copyWith(ratedIds: {...state.ratedIds, bookingId}));
  }
}
