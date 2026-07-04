import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/ride_models.dart';
import '../../../data/repositories/ride_repository.dart';

part 'taxi_state.dart';

class TaxiCubit extends Cubit<TaxiState> {
  TaxiCubit(this._repository) : super(const TaxiState());

  final RideRepository _repository;

  Future<void> loadRideOptions() async {
    emit(state.copyWith(status: TaxiStatus.loading));
    try {
      final location = await _repository.getCurrentTrip();
      final rideTypes = await _repository.getRideTypes();
      emit(state.copyWith(
        status: TaxiStatus.ready,
        location: location,
        rideTypes: rideTypes,
        selectedRideTypeId: rideTypes.isNotEmpty ? rideTypes.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: TaxiStatus.error, errorMessage: e.toString()));
    }
  }

  void selectRideType(String rideTypeId) {
    emit(state.copyWith(selectedRideTypeId: rideTypeId));
  }

  Future<void> findDriver() async {
    final rideTypeId = state.selectedRideTypeId;
    if (rideTypeId == null) return;
    emit(state.copyWith(status: TaxiStatus.searching));
    try {
      final driver = await _repository.findDrivers(rideTypeId);
      emit(state.copyWith(status: TaxiStatus.driverFound, driverMatch: driver));
    } catch (e) {
      emit(state.copyWith(status: TaxiStatus.error, errorMessage: e.toString()));
    }
  }
}
