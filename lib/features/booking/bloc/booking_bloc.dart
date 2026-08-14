import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/models/booking_models.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/repositories/payment_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

/// The booking flow for one listing: pick a day and an arrival window, pay,
/// and place the order.
///
/// The service being booked is a seller's listing now. The screens and the
/// models are unchanged; what moved is where the slots come from (generated
/// here, as in the other verticals) and what confirming writes (an ad order).
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._marketplace, this._paymentRepository, this._preferences)
      : super(const BookingState()) {
    on<BookingDetailsRequested>(_onDetailsRequested);
    on<BookingDateSelected>(_onDateSelected);
    on<BookingTimeSelected>(_onTimeSelected);
    on<BookingAddressSelected>(_onAddressSelected);
    on<ProceedToPaymentRequested>(_onProceedToPayment);
    on<BackToDateTimeRequested>(_onBackToDateTime);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<PaymentSubmitted>(_onPaymentSubmitted);
  }

  final MarketplaceRepository _marketplace;
  final PaymentRepository _paymentRepository;
  final AppPreferences _preferences;

  /// Arrival windows offered for a job. Generated rather than fetched — an
  /// order carries an instant, not a slot from a table.
  static const _slots = ['09:00', '11:00', '13:00', '15:00', '17:00', '19:00'];

  /// Flat fee shown on top of the listing price, as the screen always has.
  static const _serviceFee = 10.0;

  /// The listing being booked, held so confirming can price and address it.
  AdModel? _ad;

  Future<void> _onDetailsRequested(
    BookingDetailsRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: BookingStatus.guest));
      return;
    }
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final ad = await _marketplace.getAd(event.serviceId);
      _ad = ad;
      final details = BookingDetailsModel(
        serviceId: ad.id,
        serviceName: ad.title,
        dates: _upcomingDates(),
        // Today's earlier windows have passed; offering them would place an
        // order in the past.
        timeSlots: _availableSlots(),
        // Deliberately empty: the listing's location is where the seller is,
        // not where the buyer wants the job done. Pre-filling it would let a
        // booking through with the wrong address already accepted.
        address: '',
        pricing: PriceBreakdownModel(
          serviceFee: _serviceFee,
          // Promo codes lived in tables no seller can write to.
          promoCode: null,
          promoDiscount: 0,
          total: ad.price + _serviceFee,
        ),
      );
      emit(state.copyWith(status: BookingStatus.ready, details: details));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void _onDateSelected(BookingDateSelected event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onTimeSelected(BookingTimeSelected event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedTime: event.timeSlot));
  }

  void _onAddressSelected(
    BookingAddressSelected event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      selectedAddress: event.address,
      selectedLat: event.lat,
      selectedLng: event.lng,
    ));
  }

  Future<void> _onProceedToPayment(
    ProceedToPaymentRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (!state.canProceedToPayment) return;
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final methods = await _paymentRepository.getPaymentMethods();
      emit(state.copyWith(
        status: BookingStatus.ready,
        step: BookingStep.payment,
        paymentMethods: methods,
        selectedMethodId: methods.isNotEmpty ? methods.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void _onBackToDateTime(
    BackToDateTimeRequested event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(step: BookingStep.dateTime));
  }

  void _onPaymentMethodSelected(
    PaymentMethodSelected event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(selectedMethodId: event.methodId));
  }

  Future<void> _onPaymentSubmitted(
    PaymentSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    final details = state.details;
    final date = state.selectedDate;
    final time = state.selectedTime;
    if (details == null || date == null || time == null || !state.canSubmitPayment) {
      return;
    }

    emit(state.copyWith(status: BookingStatus.processing));
    try {
      await _paymentRepository.pay(
        methodId: state.selectedMethodId!,
        amount: details.pricing.total,
        promoCode: details.pricing.promoCode,
      );
      final order = await _marketplace.placeOrder(
        details.serviceId,
        addressText: state.effectiveAddress,
        contactPhone: _preferences.userPhone ?? '',
        // Null when the address was typed rather than picked; tracking then
        // shows it without a map.
        lat: state.selectedLat,
        lng: state.selectedLng,
        scheduledAt: _instantFor(date, time),
        // The fee the screen showed, so the order and the receipt agree.
        feesAmount: _serviceFee,
      );
      emit(state.copyWith(
        status: BookingStatus.ready,
        step: BookingStep.confirmed,
        confirmation: BookingConfirmationModel(
          bookingReference: order.code,
          serviceName: order.serviceName,
          dateTimeLabel: '${date.weekday} ${date.day}, ${time.time}',
          providerName: _ad?.sellerName ?? 'ELK Seller',
          amountPaid: details.pricing.total,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// The date strip: today plus the next six days.
  static List<DateSlotModel> _upcomingDates() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return [
      for (var i = 0; i < 7; i++)
        if (DateTime(now.year, now.month, now.day).add(Duration(days: i)) case final day)
          DateSlotModel(day: day.day, weekday: weekdays[day.weekday - 1]),
    ];
  }

  /// Windows still bookable today; a future day offers all of them.
  static List<TimeSlotModel> _availableSlots() {
    final hour = DateTime.now().hour;
    return [
      for (final slot in _slots)
        TimeSlotModel(time: slot, available: int.parse(slot.split(':')[0]) > hour),
    ];
  }

  /// The chosen day-of-month and window, as an instant.
  ///
  /// The strip only ever offers the next seven days, so a day number smaller
  /// than today's belongs to next month.
  static DateTime _instantFor(DateSlotModel date, TimeSlotModel time) {
    final now = DateTime.now();
    final hour = int.parse(time.time.split(':')[0]);
    final month = date.day < now.day ? now.month + 1 : now.month;
    return DateTime(now.year, month, date.day, hour);
  }
}
