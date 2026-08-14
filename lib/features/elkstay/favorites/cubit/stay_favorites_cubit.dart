import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../data/adapters/stay_ads_adapter.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/marketplace_repository.dart';

part 'stay_favorites_state.dart';

/// Backs the saved-stays screen.
///
/// There is no "list my saved ads" endpoint, and adding one was not worth a
/// backend change: every listing already comes back carrying `isWishlisted`
/// for the caller, so the saved ones are the category filtered by that flag.
class StayFavoritesCubit extends Cubit<StayFavoritesState> {
  StayFavoritesCubit(this._marketplace, this._preferences)
      : super(const StayFavoritesState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  Future<void> load() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: StayFavoritesStatus.guest));
      return;
    }
    emit(state.copyWith(status: StayFavoritesStatus.loading));
    try {
      final ads = await _marketplace.listAds(category: StayAdsAdapter.categorySlug);
      final stays = [
        for (final ad in ads)
          if (ad.isWishlisted) StayAdsAdapter.stay(ad),
      ];
      emit(state.copyWith(status: StayFavoritesStatus.success, stays: stays));
    } catch (e) {
      emit(state.copyWith(
        status: StayFavoritesStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Unsaves [stayId] and drops it from the list — a saved-stays screen that
  /// keeps showing what you just removed reads as a failed tap.
  Future<void> remove(String stayId) async {
    final previous = state.stays;
    emit(state.copyWith(
      stays: previous.where((s) => s.id != stayId).toList(),
    ));
    try {
      await _marketplace.setWishlisted(stayId, wishlisted: false);
    } catch (e) {
      emit(state.copyWith(
        stays: previous,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
