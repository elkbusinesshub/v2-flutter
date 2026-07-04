part of 'porter_cubit.dart';

enum PorterStatus { initial, loading, loaded, booking, booked, error }

class PorterState extends Equatable {
  const PorterState({
    this.status = PorterStatus.initial,
    this.page,
    this.selectedVehicleId,
    this.bookingReference,
    this.errorMessage,
  });

  final PorterStatus status;
  final PorterPageModel? page;
  final String? selectedVehicleId;
  final String? bookingReference;
  final String? errorMessage;

  PorterState copyWith({
    PorterStatus? status,
    PorterPageModel? page,
    String? selectedVehicleId,
    String? bookingReference,
    String? errorMessage,
  }) {
    return PorterState(
      status: status ?? this.status,
      page: page ?? this.page,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      bookingReference: bookingReference ?? this.bookingReference,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, page, selectedVehicleId, bookingReference, errorMessage];
}
