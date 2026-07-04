import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_models.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/payment_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._bookingRepository, this._paymentRepository)
      : super(const BookingState()) {
    on<BookingDetailsRequested>(_onDetailsRequested);
    on<BookingDateSelected>(_onDateSelected);
    on<BookingTimeSelected>(_onTimeSelected);
    on<ProceedToPaymentRequested>(_onProceedToPayment);
    on<BackToDateTimeRequested>(_onBackToDateTime);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<PaymentSubmitted>(_onPaymentSubmitted);
  }

  final BookingRepository _bookingRepository;
  final PaymentRepository _paymentRepository;

  Future<void> _onDetailsRequested(
    BookingDetailsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final details = await _bookingRepository.getBookingDetails(event.serviceId);
      emit(state.copyWith(status: BookingStatus.ready, details: details));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onDateSelected(BookingDateSelected event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onTimeSelected(BookingTimeSelected event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedTime: event.timeSlot));
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
        errorMessage: e.toString(),
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
      final confirmation = await _bookingRepository.confirmBooking(
        serviceId: details.serviceId,
        serviceName: details.serviceName,
        selectedDay: date.day,
        selectedWeekday: date.weekday,
        selectedTime: time.time,
        address: details.address,
        total: details.pricing.total,
      );
      emit(state.copyWith(
        status: BookingStatus.ready,
        step: BookingStep.confirmed,
        confirmation: confirmation,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
