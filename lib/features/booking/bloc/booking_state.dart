part of 'booking_bloc.dart';

enum BookingStep { dateTime, payment, confirmed }

enum BookingStatus { initial, loading, ready, processing, error }

class BookingState extends Equatable {
  const BookingState({
    this.step = BookingStep.dateTime,
    this.status = BookingStatus.initial,
    this.details,
    this.selectedDate,
    this.selectedTime,
    this.paymentMethods = const [],
    this.selectedMethodId,
    this.confirmation,
    this.errorMessage,
  });

  final BookingStep step;
  final BookingStatus status;
  final BookingDetailsModel? details;
  final DateSlotModel? selectedDate;
  final TimeSlotModel? selectedTime;
  final List<PaymentMethodModel> paymentMethods;
  final String? selectedMethodId;
  final BookingConfirmationModel? confirmation;
  final String? errorMessage;

  bool get canProceedToPayment => selectedDate != null && selectedTime != null;

  bool get canSubmitPayment => selectedMethodId != null;

  BookingState copyWith({
    BookingStep? step,
    BookingStatus? status,
    BookingDetailsModel? details,
    DateSlotModel? selectedDate,
    TimeSlotModel? selectedTime,
    List<PaymentMethodModel>? paymentMethods,
    String? selectedMethodId,
    BookingConfirmationModel? confirmation,
    String? errorMessage,
  }) {
    return BookingState(
      step: step ?? this.step,
      status: status ?? this.status,
      details: details ?? this.details,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      confirmation: confirmation ?? this.confirmation,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        details,
        selectedDate,
        selectedTime,
        paymentMethods,
        selectedMethodId,
        confirmation,
        errorMessage,
      ];
}
