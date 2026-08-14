import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../data/adapters/ad_location.dart';
import '../../../../data/adapters/stay_ads_adapter.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/marketplace_repository.dart';

part 'elkstay_home_state.dart';

/// The stays shown here are now whatever sellers have listed under `elkstay`.
/// The screen is unchanged; [StayAdsAdapter] does the translation.
class ElkStayHomeCubit extends Cubit<ElkStayHomeState> {
  ElkStayHomeCubit(this._marketplace, this._preferences)
      : super(const ElkStayHomeState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  Future<void> loadHomeData() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ElkStayHomeStatus.guest));
      return;
    }
    emit(state.copyWith(status: ElkStayHomeStatus.loading));
    try {
      final ads = await _marketplace.listAds(category: StayAdsAdapter.categorySlug);
      final stays = StayAdsAdapter.stays(ads);
      final feed = ElkStayHomeFeed(
        userName: _preferences.userName ?? '',
        location: commonestAdLocation(ads),
        categories: StayAdsAdapter.categories(ads),
        // "Top rated" was ordered by a hand-set rating nobody sets now. The
        // list is already engagement-ranked by the backend, so the best-saved
        // listings lead — which is the same promise, honestly kept.
        topRated: stays,
      );
      emit(state.copyWith(status: ElkStayHomeStatus.success, feed: feed));
    } catch (e) {
      emit(state.copyWith(
        status: ElkStayHomeStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
