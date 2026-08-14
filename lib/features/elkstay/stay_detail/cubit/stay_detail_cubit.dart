import 'package:equatable/equatable.dart';
import '../../../../core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../data/adapters/stay_ads_adapter.dart';
import '../../../../data/models/ad_models.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/marketplace_repository.dart';

part 'stay_detail_state.dart';

/// One listing's detail page, plus the two things a renter can do with it:
/// ask to book it, or ask to see it first. Both become orders against the
/// listing — a visit is the same order with no term and no deposit.
class StayDetailCubit extends Cubit<StayDetailState> {
  StayDetailCubit(this._marketplace, this._preferences)
      : super(const StayDetailState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  /// The listing behind the page, held for its price and deposit.
  AdModel? _ad;

  Future<void> loadDetail(String stayId) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: StayDetailStatus.guest));
      return;
    }
    emit(state.copyWith(status: StayDetailStatus.loading));
    try {
      final ad = await _marketplace.getAd(stayId);
      _ad = ad;
      final detail = StayAdsAdapter.detail(ad);
      emit(state.copyWith(
        status: StayDetailStatus.success,
        stay: detail.stay,
        isSaved: detail.isSaved,
        roomOptions: detail.roomOptions,
        selectedRoomOptionId: detail.roomOptions.firstOrNull?.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StayDetailStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Optimistic save/unsave — reverts if the backend rejects it.
  Future<void> toggleSaved() async {
    final stay = state.stay;
    if (stay == null) return;
    final wasSaved = state.isSaved;
    emit(state.copyWith(isSaved: !wasSaved));
    try {
      await _marketplace.setWishlisted(stay.id, wishlisted: !wasSaved);
    } catch (e) {
      emit(state.copyWith(
        isSaved: wasSaved,
        actionError: friendlyErrorMessage(e),
      ));
    }
  }

  void selectRoomOption(String id) =>
      emit(state.copyWith(selectedRoomOptionId: id));

  /// Requests a booking for the selected room option. Returns the created
  /// booking, or null on failure ([StayDetailState.actionError] holds why).
  Future<StayBookingModel?> requestToBook({
    required String moveInDate,
    required int durationMonths,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final stay = state.stay;
    final roomOptionId = state.selectedRoomOptionId;
    if (stay == null || roomOptionId == null) {
      emit(state.copyWith(actionError: L10n.current.chooseRoomFirst));
      return null;
    }
    emit(state.copyWith(isSubmitting: true, actionError: null));
    try {
      final order = await _marketplace.placeOrder(
        stay.id,
        addressText: stay.fullAddress,
        contactPhone: _preferences.userPhone ?? '',
        // The property's own pin: unlike a job, the address here is where the
        // listing is, not where the buyer lives.
        lat: _ad?.lat,
        lng: _ad?.lng,
        // Months, not rooms: the backend charges `price x quantity`, and a
        // stay is priced per month. The deposit rides alongside rather than
        // inside that total.
        quantity: durationMonths,
        scheduledAt: DateTime.parse(moveInDate),
        durationMonths: durationMonths,
        depositAmount: _ad == null ? null : StayAdsAdapter.depositOf(_ad!).toDouble(),
      );
      final booking = _asBooking(
        order: order,
        stay: stay,
        status: StayBookingStatus.confirmed,
        primaryDateLabel: 'Move-in',
        primaryDate: moveInDate,
        secondaryLabel: 'Term',
        secondaryValue: '$durationMonths months',
      );
      emit(state.copyWith(isSubmitting: false, lastBooking: booking));
      return booking;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        actionError: friendlyErrorMessage(e),
      ));
      return null;
    }
  }

  /// Schedules a property visit. [visitAt] is an ISO-8601 instant.
  Future<StayBookingModel?> scheduleVisit(String visitAt) async {
    final stay = state.stay;
    if (stay == null) return null;
    emit(state.copyWith(isSubmitting: true, actionError: null));
    try {
      final order = await _marketplace.placeOrder(
        stay.id,
        addressText: stay.fullAddress,
        contactPhone: _preferences.userPhone ?? '',
        // The property's own pin: unlike a job, the address here is where the
        // listing is, not where the buyer lives.
        lat: _ad?.lat,
        lng: _ad?.lng,
        // A viewing, not a tenancy: no term, no deposit, and nothing to pay.
        isEnquiry: true,
        scheduledAt: DateTime.parse(visitAt),
        note: 'Property visit request',
      );
      final visit = _asBooking(
        order: order,
        stay: stay,
        status: StayBookingStatus.visitBooked,
        primaryDateLabel: 'Visit',
        primaryDate: visitAt,
        secondaryLabel: 'Type',
        secondaryValue: 'Viewing',
      );
      emit(state.copyWith(isSubmitting: false, lastBooking: visit));
      return visit;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        actionError: friendlyErrorMessage(e),
      ));
      return null;
    }
  }

  /// The order, as the ticket the confirmation screen renders.
  StayBookingModel _asBooking({
    required AdOrderModel order,
    required StayModel stay,
    required StayBookingStatus status,
    required String primaryDateLabel,
    required String primaryDate,
    required String secondaryLabel,
    required String secondaryValue,
  }) =>
      StayBookingModel(
        id: order.id,
        code: order.code,
        stayName: stay.name,
        badge: stay.badge,
        roomType: stay.roomType,
        location: stay.location,
        status: status,
        primaryDateLabel: primaryDateLabel,
        primaryDate: primaryDate,
        rentPerMonth: stay.pricePerMonth,
        secondaryLabel: secondaryLabel,
        secondaryValue: secondaryValue,
        gradientStart: stay.gradientStart,
        gradientEnd: stay.gradientEnd,
      );
}
