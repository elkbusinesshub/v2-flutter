import 'package:equatable/equatable.dart';
import '../../../core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/order_models.dart';
import '../../../data/repositories/tracking_repository.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._repository, this._preferences) : super(const TrackingState());

  final TrackingRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadTracking(String orderId) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: TrackingStatus.guest));
      return;
    }
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final tracking = await _repository.getOrderTracking(orderId);
      emit(state.copyWith(status: TrackingStatus.loaded, tracking: tracking));
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Cancels, then reloads so the timeline shows the cancelled state rather
  /// than the stale "Arriving soon". Returns `(ok, message)` — the caller only
  /// navigates away when the cancellation actually landed.
  Future<({bool ok, String message})> cancelOrder(String orderId) async {
    emit(state.copyWith(isCancelling: true));
    try {
      await _repository.cancelOrder(orderId);
      final tracking = await _repository.getOrderTracking(orderId);
      emit(state.copyWith(
        status: TrackingStatus.loaded,
        tracking: tracking,
        isCancelling: false,
      ));
      return (ok: true, message: L10n.current.orderCancelled);
    } catch (e) {
      emit(state.copyWith(isCancelling: false));
      return (ok: false, message: friendlyErrorMessage(e));
    }
  }
}
