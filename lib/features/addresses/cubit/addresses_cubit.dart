import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/location_models.dart';
import '../../../data/repositories/locations_repository.dart';

part 'addresses_state.dart';

/// Backs the saved-addresses screen — the first UI over `/locations`.
/// Until now addresses could only be created inline inside a booking flow,
/// with no way to rename, re-default or remove one.
class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._repository, this._preferences)
      : super(const AddressesState());

  final LocationsRepository _repository;
  final AppPreferences _preferences;

  /// Bengaluru city centre. The backend does no geocoding and the app has no maps
  /// SDK yet, so a manually typed address is pinned here — matching what the
  /// ElkClean/ElkRep flows already do.
  static const fallbackLat = 12.9716;
  static const fallbackLng = 77.5946;

  Future<void> load() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: AddressesStatus.guest));
      return;
    }
    emit(state.copyWith(status: AddressesStatus.loading));
    try {
      final addresses = await _repository.getAddresses();
      emit(state.copyWith(status: AddressesStatus.loaded, addresses: addresses));
    } catch (e) {
      emit(state.copyWith(
        status: AddressesStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Returns an error message, or `null` on success. Each mutation reloads so
  /// the list reflects the server — notably `isDefault`, which the backend
  /// clears on the previous default.
  Future<String?> addAddress({required String label, required String line}) =>
      _mutate(() => _repository.addAddress(
            label: label,
            formattedAddress: line,
            lat: fallbackLat,
            lng: fallbackLng,
            isDefault: state.addresses.isEmpty ? true : null,
          ));

  Future<String?> rename(String id, String label) =>
      _mutate(() => _repository.updateAddress(id, label: label), busyId: id);

  Future<String?> setDefault(String id) =>
      _mutate(() => _repository.updateAddress(id, isDefault: true), busyId: id);

  Future<String?> remove(String id) =>
      _mutate(() => _repository.deleteAddress(id), busyId: id);

  Future<String?> _mutate(Future<void> Function() call, {String? busyId}) async {
    emit(state.copyWith(busyId: busyId));
    try {
      await call();
      final addresses = await _repository.getAddresses();
      emit(state.copyWith(
        status: AddressesStatus.loaded,
        addresses: addresses,
      ).clearingBusyId());
      return null;
    } catch (e) {
      emit(state.clearingBusyId());
      return friendlyErrorMessage(e);
    }
  }
}
