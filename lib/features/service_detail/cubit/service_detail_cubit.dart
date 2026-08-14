import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/adapters/services_ads_adapter.dart';
import '../../../data/models/service_models.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'service_detail_state.dart';

/// One listing's detail page. The screen is unchanged;
/// [ServicesAdsAdapter] maps the listing onto the model it renders.
class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  ServiceDetailCubit(this._marketplace, this._preferences)
      : super(const ServiceDetailState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  Future<void> loadDetail(String serviceId) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ServiceDetailStatus.guest));
      return;
    }
    emit(state.copyWith(status: ServiceDetailStatus.loading));
    try {
      final detail = ServicesAdsAdapter.detail(await _marketplace.getAd(serviceId));
      emit(state.copyWith(status: ServiceDetailStatus.loaded, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceDetailStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
