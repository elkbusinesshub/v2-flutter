import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_earnings_state.dart';

class ProviderEarningsCubit extends Cubit<ProviderEarningsState> {
  ProviderEarningsCubit(this._repository) : super(const ProviderEarningsState());

  final ProviderRepository _repository;

  Future<void> loadEarnings() async {
    emit(state.copyWith(status: ProviderEarningsStatus.loading));
    try {
      final summary = await _repository.getEarnings();
      emit(state.copyWith(status: ProviderEarningsStatus.loaded, summary: summary));
    } catch (e) {
      emit(state.copyWith(status: ProviderEarningsStatus.error, errorMessage: e.toString()));
    }
  }
}
