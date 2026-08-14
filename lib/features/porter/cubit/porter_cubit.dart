import 'package:equatable/equatable.dart';
import '../../../core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/location/trip_point.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/porter_models.dart';
import '../../../data/repositories/porter_repository.dart';

part 'porter_state.dart';

/// Owns the whole porter journey — the vehicle/add-on picker screen and the
/// scheduling + payment flow that continues from it, which is why the same
/// cubit instance is handed to the flow.
class PorterCubit extends Cubit<PorterState> {
  PorterCubit(this._repository, this._preferences) : super(const PorterState());

  final PorterRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadOptions() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: PorterStatus.guest));
      return;
    }
    emit(state.copyWith(status: PorterStatus.loading));
    try {
      final page = await _repository.getPorterOptions();
      emit(state.copyWith(
        status: PorterStatus.loaded,
        page: page,
        selectedVehicleId:
            state.selectedVehicleId ?? page.vehicles.firstOrNull?.id,
      ));
      await refreshQuote();
    } catch (e) {
      emit(state.copyWith(
        status: PorterStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  Future<void> selectVehicle(String vehicleId) async {
    emit(state.copyWith(selectedVehicleId: vehicleId));
    await refreshQuote();
  }

  Future<void> toggleAddon(String addonId) async {
    final addons = {...state.selectedAddonIds};
    if (!addons.remove(addonId)) addons.add(addonId);
    emit(state.copyWith(selectedAddonIds: addons));
    await refreshQuote();
  }

  void setRoute({TripPoint? pickup, TripPoint? drop}) => emit(state.copyWith(
        pickup: pickup,
        drop: drop,
      ));

  void setSchedule({String? date, String? window}) => emit(state.copyWith(
        scheduledDate: date,
        pickupWindow: window,
      ));

  /// Clears the schedule — "pick up now".
  void clearSchedule() => emit(state.clearingSchedule());

  void selectPaymentMethod(String method) =>
      emit(state.copyWith(paymentMethod: method));

  /// Re-prices the current vehicle + add-ons server-side.
  Future<void> refreshQuote() async {
    final vehicleId = state.selectedVehicleId;
    if (vehicleId == null) return;
    emit(state.copyWith(isQuoting: true));
    try {
      final breakdown = await _repository.quote(
        vehicleId: vehicleId,
        addons: state.selectedAddonIds.toList(),
      );
      emit(state.copyWith(isQuoting: false, breakdown: breakdown));
    } catch (e) {
      emit(state.copyWith(
        isQuoting: false,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Creates the delivery. Returns true on success — the confirmation is in
  /// [PorterState.booking].
  Future<bool> bookPorter() async {
    final vehicleId = state.selectedVehicleId;
    if (vehicleId == null) return false;
    // A blank pickup or drop would be stored as an empty address on a real
    // delivery, so refuse rather than guess.
    if (state.pickupAddress.isEmpty || state.dropAddress.isEmpty) {
      emit(state.copyWith(bookingError: L10n.current.setPickupAndDrop));
      return false;
    }
    emit(state.copyWith(status: PorterStatus.booking, bookingError: null));
    try {
      final booking = await _repository.createBooking(
        vehicleId: vehicleId,
        addons: state.selectedAddonIds.toList(),
        pickupAddress: state.pickupAddress,
        dropAddress: state.dropAddress,
        paymentMethod: state.paymentMethod,
        packageType: state.page?.route.packageType,
        weightLabel: state.page?.route.weight,
        scheduledDate: state.scheduledDate,
        pickupWindow: state.pickupWindow,
      );
      emit(state.copyWith(
        status: PorterStatus.booked,
        booking: booking,
        bookingReference: booking.code,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: PorterStatus.loaded,
        bookingError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }
}
