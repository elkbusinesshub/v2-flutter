import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/offer_models.dart';
import '../../../data/repositories/offers_repository.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(this._repository, this._preferences) : super(const OffersState());

  final OffersRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadOffers() async {
    // The page is per-user — the points balance comes from the account.
    if (_preferences.isGuest) {
      emit(state.copyWith(status: OffersStatus.guest));
      return;
    }
    emit(state.copyWith(status: OffersStatus.loading));
    try {
      final page = await _repository.getOffers();
      emit(state.copyWith(status: OffersStatus.loaded, page: page));
    } catch (e) {
      emit(state.copyWith(
        status: OffersStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
