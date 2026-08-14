part of 'booking_bloc.dart';

enum BookingStep { dateTime, payment, confirmed }

enum BookingStatus { initial, loading, ready, processing, error, guest }

class BookingState extends Equatable {
  const BookingState({
    this.step = BookingStep.dateTime,
    this.status = BookingStatus.initial,
    this.details,
    this.selectedDate,
    this.selectedTime,
    this.selectedAddress,
    this.selectedLat,
    this.selectedLng,
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

  /// Address picked on the booking screen; falls back to the profile's
  /// prefilled default in [effectiveAddress].
  final String? selectedAddress;

  /// Coordinate of [selectedAddress], sent with the booking so tracking can
  /// map it. Null when the address was typed rather than picked.
  final double? selectedLat;
  final double? selectedLng;
  final List<PaymentMethodModel> paymentMethods;
  final String? selectedMethodId;
  final BookingConfirmationModel? confirmation;
  final String? errorMessage;

  /// The address the booking is submitted with — the backend rejects
  /// empty addresses, so [canProceedToPayment] requires one.
  String get effectiveAddress => selectedAddress ?? details?.address ?? '';

  bool get canProceedToPayment =>
      selectedDate != null && selectedTime != null && effectiveAddress.isNotEmpty;

  bool get canSubmitPayment => selectedMethodId != null;

  BookingState copyWith({
    BookingStep? step,
    BookingStatus? status,
    BookingDetailsModel? details,
    DateSlotModel? selectedDate,
    TimeSlotModel? selectedTime,
    String? selectedAddress,
    double? selectedLat,
    double? selectedLng,
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
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedLat: selectedLat ?? this.selectedLat,
      selectedLng: selectedLng ?? this.selectedLng,
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
        selectedAddress,
        selectedLat,
        selectedLng,
        paymentMethods,
        selectedMethodId,
        confirmation,
        errorMessage,
      ];
}
