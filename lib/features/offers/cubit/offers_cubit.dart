import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/offer_models.dart';
import '../../../data/repositories/offers_repository.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(this._repository) : super(const OffersState());

  final OffersRepository _repository;

  Future<void> loadOffers() async {
    emit(state.copyWith(status: OffersStatus.loading));
    try {
      final page = await _repository.getOffers();
      emit(state.copyWith(status: OffersStatus.loaded, page: page));
    } catch (e) {
      emit(state.copyWith(status: OffersStatus.error, errorMessage: e.toString()));
    }
  }
}
