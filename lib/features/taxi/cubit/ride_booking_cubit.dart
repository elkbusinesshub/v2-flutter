import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/models/ride_models.dart';
import '../../../data/repositories/ride_repository.dart';

part 'ride_booking_state.dart';

/// Drives the ride booking flow end to end: ride classes and the route
/// estimate, the driver-match preview, booking creation (which issues the
/// pickup OTP), then start → complete → rate.
///
/// Screen sequencing, timers and the card form stay in the flow widget.
class RideBookingCubit extends Cubit<RideBookingState> {
  RideBookingCubit(this._repository) : super(const RideBookingState());

  final RideRepository _repository;

  Future<void> loadOptions() async {
    emit(state.copyWith(optionsStatus: RideOptionsStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getRideTypes(),
        _repository.getCurrentTrip(),
      ]);
      final rideTypes = results[0] as List<RideTypeModel>;
      final estimate = results[1] as TaxiLocationModel;
      emit(state.copyWith(
        optionsStatus: RideOptionsStatus.loaded,
        rideTypes: rideTypes,
        estimate: estimate,
        selectedRideTypeId: state.selectedRideTypeId ?? rideTypes.firstOrNull?.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        optionsStatus: RideOptionsStatus.error,
        optionsError: friendlyErrorMessage(e),
      ));
    }
  }

  void selectRideType(String id) => emit(state.copyWith(selectedRideTypeId: id));

  void selectPaymentMethod(String method) =>
      emit(state.copyWith(paymentMethod: method));

  /// Driver-match preview shown on the "finding a driver" screen. Nothing is
  /// booked yet — [confirmBooking] assigns the real driver.
  Future<bool> previewDriver() async {
    final rideTypeId = state.selectedRideTypeId;
    if (rideTypeId == null) return false;
    emit(state.copyWith(isSearching: true, actionError: null));
    try {
      final match = await _repository.findDrivers(rideTypeId);
      emit(state.copyWith(isSearching: false, driverMatch: match));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        actionError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }

  /// Creates the ride. On success [RideBookingState.booking] carries the
  /// assigned driver, the pickup OTP and the tracking code.
  Future<bool> confirmBooking({
    required String pickupAddress,
    required String dropAddress,
  }) async {
    final rideTypeId = state.selectedRideTypeId;
    if (rideTypeId == null) return false;
    emit(state.copyWith(isSubmitting: true, actionError: null));
    try {
      final booking = await _repository.createBooking(
        rideTypeId: rideTypeId,
        pickupAddress: pickupAddress,
        dropAddress: dropAddress,
        paymentMethod: state.paymentMethod,
      );
      emit(state.copyWith(isSubmitting: false, booking: booking));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        actionError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }

  /// Confirms the pickup OTP with the driver and starts the trip.
  Future<bool> startRide(String otpCode) =>
      _lifecycle(() => _repository.startRide(state.booking!.id, otpCode));

  Future<bool> completeRide() =>
      _lifecycle(() => _repository.completeRide(state.booking!.id));

  /// Rates the driver (1–5 stars) with an optional tip.
  Future<bool> rateRide({required int stars, int tip = 0}) => _lifecycle(
        () => _repository.rateRide(state.booking!.id, stars: stars, tip: tip),
      );

  Future<bool> cancelRide() async {
    final booking = state.booking;
    if (booking == null) return false;
    emit(state.copyWith(isSubmitting: true, actionError: null));
    try {
      await _repository.cancelRide(booking.id);
      emit(state.copyWith(isSubmitting: false, isCancelled: true));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        actionError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }

  /// Shared shape for the lifecycle transitions, which all return the
  /// updated booking or a message to show.
  Future<bool> _lifecycle(Future<RideBookingModel> Function() action) async {
    if (state.booking == null) return false;
    emit(state.copyWith(isSubmitting: true, actionError: null));
    try {
      final updated = await action();
      emit(state.copyWith(isSubmitting: false, booking: updated));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        actionError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }
}
