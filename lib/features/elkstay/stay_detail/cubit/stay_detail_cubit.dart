import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/elkstay_repository.dart';

part 'stay_detail_state.dart';

class StayDetailCubit extends Cubit<StayDetailState> {
  StayDetailCubit(this._repository) : super(const StayDetailState());

  final ElkStayRepository _repository;

  Future<void> loadDetail(String stayId) async {
    emit(state.copyWith(status: StayDetailStatus.loading));
    try {
      final stay = await _repository.fetchStayDetail(stayId);
      emit(state.copyWith(status: StayDetailStatus.success, stay: stay));
    } catch (e) {
      emit(state.copyWith(
        status: StayDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void toggleSaved() => emit(state.copyWith(isSaved: !state.isSaved));
}
