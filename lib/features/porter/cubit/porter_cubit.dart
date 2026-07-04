import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/porter_models.dart';
import '../../../data/repositories/porter_repository.dart';

part 'porter_state.dart';

class PorterCubit extends Cubit<PorterState> {
  PorterCubit(this._repository) : super(const PorterState());

  final PorterRepository _repository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: PorterStatus.loading));
    try {
      final page = await _repository.getPorterOptions();
      emit(state.copyWith(
        status: PorterStatus.loaded,
        page: page,
        selectedVehicleId: page.vehicles.isNotEmpty ? page.vehicles.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: PorterStatus.error, errorMessage: e.toString()));
    }
  }

  void selectVehicle(String vehicleId) {
    emit(state.copyWith(selectedVehicleId: vehicleId));
  }

  Future<void> bookPorter() async {
    final vehicleId = state.selectedVehicleId;
    if (vehicleId == null) return;
    emit(state.copyWith(status: PorterStatus.booking));
    try {
      final reference = await _repository.bookPorter(vehicleId: vehicleId);
      emit(state.copyWith(status: PorterStatus.booked, bookingReference: reference));
    } catch (e) {
      emit(state.copyWith(status: PorterStatus.error, errorMessage: e.toString()));
    }
  }
}
