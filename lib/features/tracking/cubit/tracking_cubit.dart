import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/order_models.dart';
import '../../../data/repositories/tracking_repository.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._repository) : super(const TrackingState());

  final TrackingRepository _repository;

  Future<void> loadTracking(String orderId) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final tracking = await _repository.getOrderTracking(orderId);
      emit(state.copyWith(status: TrackingStatus.loaded, tracking: tracking));
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    emit(state.copyWith(isCancelling: true));
    try {
      await _repository.cancelOrder(orderId);
      emit(state.copyWith(isCancelling: false));
    } catch (e) {
      emit(state.copyWith(isCancelling: false, errorMessage: e.toString()));
    }
  }
}
