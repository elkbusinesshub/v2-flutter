import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/rental_models.dart';
import '../../../data/repositories/rental_repository.dart';

part 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  RentalCubit(this._repository) : super(const RentalState());

  final RentalRepository _repository;

  Future<void> loadCars() async {
    emit(state.copyWith(status: RentalStatus.loading));
    try {
      final cars = await _repository.getCars(
        period: state.period,
        typeFilter: state.typeFilter,
      );
      emit(state.copyWith(status: RentalStatus.loaded, cars: cars));
    } catch (e) {
      emit(state.copyWith(status: RentalStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> selectPeriod(RentalPeriod period) async {
    emit(state.copyWith(period: period));
    await loadCars();
  }

  Future<void> selectTypeFilter(String typeFilter) async {
    emit(state.copyWith(typeFilter: typeFilter));
    await loadCars();
  }
}
