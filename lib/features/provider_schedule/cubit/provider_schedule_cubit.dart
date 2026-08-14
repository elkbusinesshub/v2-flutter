import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_schedule_state.dart';

class ProviderScheduleCubit extends Cubit<ProviderScheduleState> {
  ProviderScheduleCubit(this._repository, this._preferences)
      : super(const ProviderScheduleState());

  final ProviderRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadSchedule() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ProviderScheduleStatus.guest));
      return;
    }
    emit(state.copyWith(status: ProviderScheduleStatus.loading));
    try {
      final schedule = await _repository.getSchedule();
      emit(state.copyWith(status: ProviderScheduleStatus.loaded, schedule: schedule));
    } catch (e) {
      emit(state.copyWith(
        status: isProviderNotRegistered(e)
            ? ProviderScheduleStatus.notRegistered
            : ProviderScheduleStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
