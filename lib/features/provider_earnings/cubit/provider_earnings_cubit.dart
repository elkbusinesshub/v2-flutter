import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_earnings_state.dart';

class ProviderEarningsCubit extends Cubit<ProviderEarningsState> {
  ProviderEarningsCubit(this._repository, this._preferences)
      : super(const ProviderEarningsState());

  final ProviderRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadEarnings() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ProviderEarningsStatus.guest));
      return;
    }
    emit(state.copyWith(status: ProviderEarningsStatus.loading));
    try {
      final summary = await _repository.getEarnings();
      emit(state.copyWith(status: ProviderEarningsStatus.loaded, summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: isProviderNotRegistered(e)
            ? ProviderEarningsStatus.notRegistered
            : ProviderEarningsStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
