part of 'ride_booking_cubit.dart';

enum RideOptionsStatus { initial, loading, loaded, error }

class RideBookingState extends Equatable {
  const RideBookingState({
    this.optionsStatus = RideOptionsStatus.initial,
    this.rideTypes = const [],
    this.nearbyVehicles = const [],
    this.estimate,
    this.optionsError,
    this.selectedRideTypeId,
    this.paymentMethod = 'card',
    this.isSearching = false,
    this.driverMatch,
    this.isSubmitting = false,
    this.booking,
    this.isCancelled = false,
    this.actionError,
  });

  final RideOptionsStatus optionsStatus;
  final List<RideTypeModel> rideTypes;

  /// Partners on duty near the pickup, as map pins. Empty means nobody is
  /// out there — which the map shows honestly rather than inventing cars.
  final List<NearbyVehicleModel> nearbyVehicles;
  final TaxiLocationModel? estimate;
  final String? optionsError;

  final String? selectedRideTypeId;
  final String paymentMethod;

  final bool isSearching;

  /// Preview shown while searching; superseded by [booking]'s real driver.
  final DriverMatchModel? driverMatch;

  final bool isSubmitting;
  final RideBookingModel? booking;
  final bool isCancelled;
  final String? actionError;

  RideTypeModel? get selectedRideType =>
      rideTypes.where((t) => t.id == selectedRideTypeId).firstOrNull;

  /// The driver to display: the booked one once it exists, else the preview.
  String? get driverName => booking?.driverName ?? driverMatch?.driverName;
  String? get vehicle => booking?.vehicle ?? driverMatch?.vehicle;
  String? get plateNumber => booking?.plateNumber ?? driverMatch?.plateNumber;

  RideBookingState copyWith({
    RideOptionsStatus? optionsStatus,
    List<RideTypeModel>? rideTypes,
    List<NearbyVehicleModel>? nearbyVehicles,
    TaxiLocationModel? estimate,
    String? optionsError,
    String? selectedRideTypeId,
    String? paymentMethod,
    bool? isSearching,
    DriverMatchModel? driverMatch,
    bool? isSubmitting,
    RideBookingModel? booking,
    bool? isCancelled,
    String? actionError,
  }) {
    return RideBookingState(
      optionsStatus: optionsStatus ?? this.optionsStatus,
      rideTypes: rideTypes ?? this.rideTypes,
      nearbyVehicles: nearbyVehicles ?? this.nearbyVehicles,
      estimate: estimate ?? this.estimate,
      optionsError: optionsError,
      selectedRideTypeId: selectedRideTypeId ?? this.selectedRideTypeId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSearching: isSearching ?? this.isSearching,
      driverMatch: driverMatch ?? this.driverMatch,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      booking: booking ?? this.booking,
      isCancelled: isCancelled ?? this.isCancelled,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
        optionsStatus,
        rideTypes,
        nearbyVehicles,
        estimate,
        optionsError,
        selectedRideTypeId,
        paymentMethod,
        isSearching,
        driverMatch,
        isSubmitting,
        booking,
        isCancelled,
        actionError,
      ];
}
