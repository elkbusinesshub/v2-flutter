part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingDetailsRequested extends BookingEvent {
  const BookingDetailsRequested(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

class BookingDateSelected extends BookingEvent {
  const BookingDateSelected(this.date);

  final DateSlotModel date;

  @override
  List<Object?> get props => [date];
}

class BookingTimeSelected extends BookingEvent {
  const BookingTimeSelected(this.timeSlot);

  final TimeSlotModel timeSlot;

  @override
  List<Object?> get props => [timeSlot];
}

class ProceedToPaymentRequested extends BookingEvent {
  const ProceedToPaymentRequested();
}

class BackToDateTimeRequested extends BookingEvent {
  const BackToDateTimeRequested();
}

class PaymentMethodSelected extends BookingEvent {
  const PaymentMethodSelected(this.methodId);

  final String methodId;

  @override
  List<Object?> get props => [methodId];
}

class PaymentSubmitted extends BookingEvent {
  const PaymentSubmitted();
}
