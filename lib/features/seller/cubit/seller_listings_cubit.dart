import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'seller_listings_state.dart';

/// Backs My Listings and the "Post a new ad" sheet.
///
/// Until now the seller panel ran entirely on `seller_data.dart` fixtures —
/// hardcoded tab counts sitting above permanently empty lists. This is the
/// first thing on that screen that talks to the backend.
class SellerListingsCubit extends Cubit<SellerListingsState> {
  SellerListingsCubit(this._repository) : super(const SellerListingsState());

  final MarketplaceRepository _repository;

  /// Loads every status in one call; the tabs filter client-side so switching
  /// between them is instant and the counts are always consistent with the
  /// rows beneath them.
  Future<void> load() async {
    emit(state.copyWith(status: SellerListingsStatus.loading));
    try {
      final ads = await _repository.myAds();
      emit(state.copyWith(status: SellerListingsStatus.success, ads: ads));
    } catch (e) {
      emit(state.copyWith(
        status: SellerListingsStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void selectTab(AdStatus? tab) => emit(state.copyWith(tab: tab, clearTab: tab == null));

  /// Publishes or drafts a new listing. Returns true on success; the sheet
  /// stays open on failure so the seller does not lose what they typed.
  Future<bool> create({
    required String title,
    required String categorySlug,
    required double price,
    String? description,
    String? priceUnit,
    String? icon,
    AdStatus status = AdStatus.active,
    List<String> imageKeys = const [],
    Map<String, dynamic> attributes = const {},
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      final ad = await _repository.createAd(
        title: title,
        categorySlug: categorySlug,
        price: price,
        description: description,
        priceUnit: priceUnit,
        icon: icon,
        status: status,
        imageKeys: imageKeys,
        attributes: attributes,
      );
      emit(state.copyWith(ads: [ad, ...state.ads], isSaving: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: friendlyErrorMessage(e)));
      return false;
    }
  }

  /// Pauses a live listing or puts a paused one back on sale.
  Future<void> setPaused(String adId, bool paused) async {
    final previous = state.ads;
    final next = paused ? AdStatus.paused : AdStatus.active;
    // Optimistic: the row's badge and its tab move together, and a failure
    // puts both back.
    emit(state.copyWith(ads: _replace(previous, adId, (a) => a.copyWith(status: next))));
    try {
      final updated = await _repository.updateAd(adId, status: next);
      emit(state.copyWith(ads: _replace(state.ads, adId, (_) => updated)));
    } catch (e) {
      emit(state.copyWith(ads: previous, errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> delete(String adId) async {
    final previous = state.ads;
    emit(state.copyWith(ads: previous.where((a) => a.id != adId).toList()));
    try {
      await _repository.deleteAd(adId);
    } catch (e) {
      emit(state.copyWith(ads: previous, errorMessage: friendlyErrorMessage(e)));
    }
  }

  static List<AdModel> _replace(
    List<AdModel> ads,
    String id,
    AdModel Function(AdModel) update,
  ) {
    return [
      for (final ad in ads) if (ad.id == id) update(ad) else ad,
    ];
  }
}
