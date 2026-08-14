part of 'porter_cubit.dart';

enum PorterStatus { initial, loading, loaded, booking, booked, error, guest }

class PorterState extends Equatable {
  const PorterState({
    this.status = PorterStatus.initial,
    this.page,
    this.selectedVehicleId,
    this.selectedAddonIds = const {},
    this.pickup = const TripPoint.empty(),
    this.drop = const TripPoint.empty(),
    this.scheduledDate,
    this.pickupWindow,
    this.paymentMethod = 'wallet',
    this.isQuoting = false,
    this.breakdown,
    this.booking,
    this.bookingReference,
    this.bookingError,
    this.errorMessage,
  });

  final PorterStatus status;
  final PorterPageModel? page;
  final String? selectedVehicleId;
  final Set<String> selectedAddonIds;

  /// Both ends of the route, empty until the user picks them or GPS fills the
  /// pickup. Never defaulted to a real-looking address — those were being
  /// submitted verbatim with the booking.
  ///
  /// They carry coordinates as well as text so the map can draw the route; the
  /// booking payload still sends only the address.
  final TripPoint pickup;
  final TripPoint drop;

  String get pickupAddress => pickup.address;
  String get dropAddress => drop.address;

  /// Both ends of the route are known, so the booking can proceed.
  bool get hasRoute => pickup.isNotEmpty && drop.isNotEmpty;

  /// `YYYY-MM-DD` + window label; both null means "pick up now".
  final String? scheduledDate;
  final String? pickupWindow;
  final String paymentMethod;

  final bool isQuoting;

  /// Server-priced fare for the current selection.
  final PorterBreakdown? breakdown;

  final PorterBookingModel? booking;
  final String? bookingReference;
  final String? bookingError;
  final String? errorMessage;

  PorterVehicleModel? get selectedVehicle =>
      page?.vehicles.where((v) => v.id == selectedVehicleId).firstOrNull;

  bool get isScheduled => scheduledDate != null && pickupWindow != null;

  double get baseFare => breakdown?.baseFare ?? selectedVehicle?.baseFare ?? 0;
  double get addonsTotal => breakdown?.addonsTotal ?? 0;
  double get serviceFee => breakdown?.serviceFee ?? page?.serviceFee ?? 0;
  double get vatAmount => breakdown?.vatAmount ?? 0;

  /// Fare shown on the picker screen (before fees) and the full total.
  double get fareBeforeFees => baseFare + addonsTotal;
  double get totalAmount => breakdown?.totalAmount ?? fareBeforeFees;

  PorterState copyWith({
    PorterStatus? status,
    PorterPageModel? page,
    String? selectedVehicleId,
    Set<String>? selectedAddonIds,
    TripPoint? pickup,
    TripPoint? drop,
    String? scheduledDate,
    String? pickupWindow,
    String? paymentMethod,
    bool? isQuoting,
    PorterBreakdown? breakdown,
    PorterBookingModel? booking,
    String? bookingReference,
    String? bookingError,
    String? errorMessage,
  }) {
    return PorterState(
      status: status ?? this.status,
      page: page ?? this.page,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      selectedAddonIds: selectedAddonIds ?? this.selectedAddonIds,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      pickupWindow: pickupWindow ?? this.pickupWindow,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isQuoting: isQuoting ?? this.isQuoting,
      breakdown: breakdown ?? this.breakdown,
      booking: booking ?? this.booking,
      bookingReference: bookingReference ?? this.bookingReference,
      bookingError: bookingError,
      errorMessage: errorMessage,
    );
  }

  /// [copyWith] can't null out the schedule, so switching back to
  /// "pick up now" goes through here.
  PorterState clearingSchedule() => PorterState(
        status: status,
        page: page,
        selectedVehicleId: selectedVehicleId,
        selectedAddonIds: selectedAddonIds,
        pickup: pickup,
        drop: drop,
        paymentMethod: paymentMethod,
        isQuoting: isQuoting,
        breakdown: breakdown,
        booking: booking,
        bookingReference: bookingReference,
      );

  @override
  List<Object?> get props => [
        status,
        page,
        selectedVehicleId,
        selectedAddonIds,
        pickup,
        drop,
        scheduledDate,
        pickupWindow,
        paymentMethod,
        isQuoting,
        breakdown,
        booking,
        bookingReference,
        bookingError,
        errorMessage,
      ];
}
