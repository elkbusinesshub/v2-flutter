import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_schedule_state.dart';

class ProviderScheduleCubit extends Cubit<ProviderScheduleState> {
  ProviderScheduleCubit(this._repository) : super(const ProviderScheduleState());

  final ProviderRepository _repository;

  Future<void> loadSchedule() async {
    emit(state.copyWith(status: ProviderScheduleStatus.loading));
    try {
      final schedule = await _repository.getSchedule();
      emit(state.copyWith(status: ProviderScheduleStatus.loaded, schedule: schedule));
    } catch (e) {
      emit(state.copyWith(status: ProviderScheduleStatus.error, errorMessage: e.toString()));
    }
  }
}
