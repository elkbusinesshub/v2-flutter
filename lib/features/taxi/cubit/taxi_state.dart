part of 'taxi_cubit.dart';

enum TaxiStatus { initial, loading, ready, searching, driverFound, error }

class TaxiState extends Equatable {
  const TaxiState({
    this.status = TaxiStatus.initial,
    this.location,
    this.rideTypes = const [],
    this.selectedRideTypeId,
    this.driverMatch,
    this.errorMessage,
  });

  final TaxiStatus status;
  final TaxiLocationModel? location;
  final List<RideTypeModel> rideTypes;
  final String? selectedRideTypeId;
  final DriverMatchModel? driverMatch;
  final String? errorMessage;

  TaxiState copyWith({
    TaxiStatus? status,
    TaxiLocationModel? location,
    List<RideTypeModel>? rideTypes,
    String? selectedRideTypeId,
    DriverMatchModel? driverMatch,
    String? errorMessage,
  }) {
    return TaxiState(
      status: status ?? this.status,
      location: location ?? this.location,
      rideTypes: rideTypes ?? this.rideTypes,
      selectedRideTypeId: selectedRideTypeId ?? this.selectedRideTypeId,
      driverMatch: driverMatch ?? this.driverMatch,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        location,
        rideTypes,
        selectedRideTypeId,
        driverMatch,
        errorMessage,
      ];
}
