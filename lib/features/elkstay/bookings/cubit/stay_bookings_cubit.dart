import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/elkstay_repository.dart';

part 'stay_bookings_state.dart';

class StayBookingsCubit extends Cubit<StayBookingsState> {
  StayBookingsCubit(this._repository) : super(const StayBookingsState());

  final ElkStayRepository _repository;

  Future<void> loadBookings() async {
    emit(state.copyWith(status: StayBookingsStatus.loading));
    try {
      final bookings = await _repository.fetchBookings();
      emit(state.copyWith(status: StayBookingsStatus.success, bookings: bookings));
    } catch (e) {
      emit(state.copyWith(
        status: StayBookingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void setTab(int tab) => emit(state.copyWith(activeTab: tab));
}
