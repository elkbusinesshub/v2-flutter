import 'package:equatable/equatable.dart';
import '../../../../core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../data/adapters/stay_ads_adapter.dart';
import '../../../../data/models/ad_models.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/marketplace_repository.dart';

part 'elkstay_explore_state.dart';

/// Explore listings.
///
/// The search box still asks the backend, which matches title, category and
/// seller name. The chips filter what came back, because the properties they
/// narrow on — type, price, room type — live in a JSON column the listing
/// query cannot sort or filter by.
class ElkStayExploreCubit extends Cubit<ElkStayExploreState> {
  ElkStayExploreCubit(this._marketplace, this._preferences)
      : super(const ElkStayExploreState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  /// Everything the last search returned, before the chips narrow it.
  List<AdModel> _ads = const [];

  /// "Under ₹12k" chip.
  static const maxPriceFilter = 12000;

  /// "Single room" chip — matched against `roomType` server-side.
  static const singleRoomQuery = 'single';

  Future<void> loadStays({StayCategoryType? filter}) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ElkStayExploreStatus.guest));
      return;
    }
    emit(state.copyWith(
      status: ElkStayExploreStatus.loading,
      activeCategory: filter,
      clearCategory: filter == null,
    ));
    await _query();
  }

  Future<void> filterByCategory(StayCategoryType type) => loadStays(filter: type);

  Future<void> toggleVerified() =>
      _applyFilter(state.copyWith(verifiedOnly: !state.verifiedOnly));

  Future<void> togglePriceFilter() =>
      _applyFilter(state.copyWith(priceFilter: !state.priceFilter));

  Future<void> toggleSingleRoom() =>
      _applyFilter(state.copyWith(singleRoomOnly: !state.singleRoomOnly));

  /// Sets an explicit room-type query (`single`, `double`, …) or clears it.
  /// The shell's listing chips use this instead of the boolean toggle.
  Future<void> setRoomType(String? roomType) => _applyFilter(state.copyWith(
        roomTypeQuery: roomType ?? '',
        singleRoomOnly: false,
      ));

  Future<void> toggleMeals() =>
      _applyFilter(state.copyWith(mealsIncluded: !state.mealsIncluded));

  /// The only filter that still asks the backend — it matches title, category
  /// and seller name, which the client cannot do against a partial list.
  Future<void> search(String term) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ElkStayExploreStatus.guest));
      return;
    }
    emit(state.copyWith(searchTerm: term, status: ElkStayExploreStatus.loading));
    await _query();
  }

  /// Chips narrow what is already loaded, so toggling one costs no round trip.
  Future<void> _applyFilter(ElkStayExploreState next) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ElkStayExploreStatus.guest));
      return;
    }
    emit(next.copyWith(status: ElkStayExploreStatus.success, stays: _filteredWith(next)));
  }

  List<StayModel> _filtered() => _filteredWith(state);

  /// The chips in [s], applied to what the last search returned.
  ///
  /// Client-side because these read `Ad.attributes`, a JSON column the
  /// listing query cannot filter on. The whole category is small enough that
  /// this is a list walk, not a page of results being narrowed.
  List<StayModel> _filteredWith(ElkStayExploreState s) {
    final roomQuery =
        s.roomTypeQuery.isNotEmpty ? s.roomTypeQuery : (s.singleRoomOnly ? singleRoomQuery : null);

    return [
      for (final ad in _ads)
        if (s.activeCategory == null || StayAdsAdapter.typeOf(ad) == s.activeCategory)
          if (!s.priceFilter || ad.price <= maxPriceFilter)
            if (roomQuery == null ||
                (ad.attribute<String>('roomType') ?? '')
                    .toLowerCase()
                    .contains(roomQuery.toLowerCase()))
              // `verifiedOnly` and `mealsIncluded` were an admin flag and an
              // amenity row. Nothing sets either now, so those chips match
              // everything rather than silently emptying the screen.
              StayAdsAdapter.stay(ad),
    ];
  }

  Future<void> _query() async {
    try {
      _ads = await _marketplace.listAds(
        category: StayAdsAdapter.categorySlug,
        // The backend rejects a one-character search, and an empty one means
        // "everything".
        query: state.searchTerm.trim().length >= 2 ? state.searchTerm.trim() : null,
      );
      emit(state.copyWith(status: ElkStayExploreStatus.success, stays: _filtered()));
    } catch (e) {
      emit(state.copyWith(
        status: ElkStayExploreStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
