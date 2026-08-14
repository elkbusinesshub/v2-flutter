part of 'addresses_cubit.dart';

enum AddressesStatus { initial, loading, loaded, guest, error }

class AddressesState extends Equatable {
  const AddressesState({
    this.status = AddressesStatus.initial,
    this.addresses = const [],
    this.busyId,
    this.errorMessage,
  });

  final AddressesStatus status;
  final List<AddressModel> addresses;

  /// The address currently being renamed, defaulted or removed.
  final String? busyId;
  final String? errorMessage;

  AddressModel? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull;

  AddressesState copyWith({
    AddressesStatus? status,
    List<AddressModel>? addresses,
    String? busyId,
    String? errorMessage,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      busyId: busyId ?? this.busyId,
      errorMessage: errorMessage,
    );
  }

  /// [copyWith] can't null a field, so ending a mutation goes through here.
  AddressesState clearingBusyId() => AddressesState(
        status: status,
        addresses: addresses,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, addresses, busyId, errorMessage];
}
