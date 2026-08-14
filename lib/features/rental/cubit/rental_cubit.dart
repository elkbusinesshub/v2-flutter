import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/adapters/rental_ads_adapter.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/models/rental_models.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'rental_state.dart';

/// The rental catalogue is now whatever sellers have listed under
/// `car_rental`. The screen is unchanged; [RentalAdsAdapter] does the whole
/// translation.
class RentalCubit extends Cubit<RentalState> {
  RentalCubit(this._marketplace, this._preferences) : super(const RentalState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  /// Every rental listing from the last fetch. The chips filter this rather
  /// than refetching, so switching them costs no round trip.
  List<AdModel> _ads = const [];

  Future<void> loadCars() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: RentalStatus.guest));
      return;
    }
    emit(state.copyWith(status: RentalStatus.loading));
    try {
      _ads = await _marketplace.listAds(category: RentalAdsAdapter.categorySlug);
      emit(state.copyWith(
        status: RentalStatus.loaded,
        cars: RentalAdsAdapter.cars(_ads, typeFilter: state.typeFilter),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Daily / weekly / monthly. The seeded catalogue repriced per period; a
  /// listing has one price, so this now only selects how long the booking
  /// runs — the cards do not change.
  Future<void> selectPeriod(RentalPeriod period) async {
    emit(state.copyWith(period: period));
  }

  void selectTypeFilter(String typeFilter) {
    emit(state.copyWith(
      typeFilter: typeFilter,
      cars: RentalAdsAdapter.cars(_ads, typeFilter: typeFilter),
    ));
  }
}
