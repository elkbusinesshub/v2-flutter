import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/location_models.dart';
import 'package:elk/data/repositories/locations_repository.dart';
import 'package:elk/features/addresses/cubit/addresses_cubit.dart';

AddressModel _address(String id, String label, {bool isDefault = false}) =>
    AddressModel(
      id: id,
      label: label,
      formattedAddress: 'Tower 3, Apt 1204, Koramangala',
      lat: 12.9716,
      lng: 77.5946,
      isDefault: isDefault,
    );

/// Mirrors the backend: setting a default clears the previous one.
class _FakeLocationsRepository implements LocationsRepository {
  List<AddressModel> addresses = [];
  Object? listError;
  Object? mutationError;
  final List<String> calls = [];
  Map<String, dynamic>? lastCreate;

  @override
  Future<List<AddressModel>> getAddresses() async {
    calls.add('list');
    if (listError != null) throw listError!;
    return addresses;
  }

  @override
  Future<AddressModel> addAddress({
    required String label,
    required String formattedAddress,
    required double lat,
    required double lng,
    bool? isDefault,
  }) async {
    calls.add('create');
    lastCreate = {
      'label': label,
      'formattedAddress': formattedAddress,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
    if (mutationError != null) throw mutationError!;
    final created = AddressModel(
      id: 'a${addresses.length + 1}',
      label: label,
      formattedAddress: formattedAddress,
      lat: lat,
      lng: lng,
      isDefault: isDefault ?? false,
    );
    addresses = [...addresses, created];
    return created;
  }

  @override
  Future<AddressModel> updateAddress(String id, {String? label, bool? isDefault}) async {
    calls.add('update:$id');
    if (mutationError != null) throw mutationError!;
    addresses = [
      for (final a in addresses)
        if (a.id == id)
          AddressModel(
            id: a.id,
            label: label ?? a.label,
            formattedAddress: a.formattedAddress,
            lat: a.lat,
            lng: a.lng,
            isDefault: isDefault ?? a.isDefault,
          )
        else
          AddressModel(
            id: a.id,
            label: a.label,
            formattedAddress: a.formattedAddress,
            lat: a.lat,
            lng: a.lng,
            isDefault: isDefault == true ? false : a.isDefault,
          ),
    ];
    return addresses.firstWhere((a) => a.id == id);
  }

  @override
  Future<void> deleteAddress(String id) async {
    calls.add('delete:$id');
    if (mutationError != null) throw mutationError!;
    addresses = addresses.where((a) => a.id != id).toList();
  }
}

void main() {
  late _FakeLocationsRepository repository;

  Future<AddressesCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return AddressesCubit(repository, preferences);
  }

  setUp(() => repository = _FakeLocationsRepository());

  test('loads saved addresses and exposes the default', () async {
    repository.addresses = [
      _address('a1', 'Home', isDefault: true),
      _address('a2', 'Office'),
    ];
    final cubit = await buildCubit();
    await cubit.load();

    expect(cubit.state.status, AddressesStatus.loaded);
    expect(cubit.state.addresses, hasLength(2));
    expect(cubit.state.defaultAddress!.label, 'Home');
  });

  test('an empty address book loads cleanly', () async {
    final cubit = await buildCubit();
    await cubit.load();

    expect(cubit.state.status, AddressesStatus.loaded);
    expect(cubit.state.addresses, isEmpty);
    expect(cubit.state.defaultAddress, isNull);
  });

  test('guest mode short-circuits before hitting the API', () async {
    repository.listError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.load();

    expect(cubit.state.status, AddressesStatus.guest);
    expect(repository.calls, isEmpty);
  });

  test('the first address is created as the default', () async {
    final cubit = await buildCubit();
    await cubit.load();

    final error = await cubit.addAddress(label: 'Home', line: 'Tower 3');
    expect(error, isNull);
    expect(repository.lastCreate!['isDefault'], isTrue);
    expect(repository.lastCreate!['lat'], AddressesCubit.fallbackLat);
    expect(repository.lastCreate!['lng'], AddressesCubit.fallbackLng);
    expect(cubit.state.addresses.single.isDefault, isTrue);
  });

  test('a later address does not steal the default', () async {
    repository.addresses = [_address('a1', 'Home', isDefault: true)];
    final cubit = await buildCubit();
    await cubit.load();

    await cubit.addAddress(label: 'Office', line: 'Business Bay');
    expect(repository.lastCreate!['isDefault'], isNull);
    expect(cubit.state.defaultAddress!.label, 'Home');
  });

  test('setting a default clears the previous one', () async {
    repository.addresses = [
      _address('a1', 'Home', isDefault: true),
      _address('a2', 'Office'),
    ];
    final cubit = await buildCubit();
    await cubit.load();

    final error = await cubit.setDefault('a2');
    expect(error, isNull);
    expect(cubit.state.defaultAddress!.label, 'Office');
    expect(cubit.state.addresses.firstWhere((a) => a.id == 'a1').isDefault, isFalse);
    // Every mutation refetches so the cleared flag comes from the server.
    expect(repository.calls, ['list', 'update:a2', 'list']);
    expect(cubit.state.busyId, isNull);
  });

  test('renaming sends only the label', () async {
    repository.addresses = [_address('a1', 'Home')];
    final cubit = await buildCubit();
    await cubit.load();

    final error = await cubit.rename('a1', 'Villa');
    expect(error, isNull);
    expect(cubit.state.addresses.single.label, 'Villa');
    // The address line is untouched by a rename.
    expect(cubit.state.addresses.single.formattedAddress,
        'Tower 3, Apt 1204, Koramangala');
  });

  test('removing drops the address', () async {
    repository.addresses = [
      _address('a1', 'Home', isDefault: true),
      _address('a2', 'Office'),
    ];
    final cubit = await buildCubit();
    await cubit.load();

    final error = await cubit.remove('a2');
    expect(error, isNull);
    expect(cubit.state.addresses.single.id, 'a1');
    expect(cubit.state.busyId, isNull);
  });

  test('a failed mutation returns its message and changes nothing', () async {
    repository.addresses = [_address('a1', 'Home', isDefault: true)];
    final cubit = await buildCubit();
    await cubit.load();
    repository.mutationError =
        const ApiException(ApiErrorType.notFound, 'Address not found');

    final error = await cubit.remove('a1');
    expect(error, 'Address not found');
    expect(cubit.state.addresses, hasLength(1));
    expect(cubit.state.busyId, isNull);
  });

  test('surfaces a friendly error when the list fails', () async {
    repository.listError =
        const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.load();

    expect(cubit.state.status, AddressesStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });

  test('AddressModel parses the backend payload', () {
    final model = AddressModel.fromJson({
      'id': '019fad5a-…',
      'label': 'Home',
      'formattedAddress': 'Tower 3, Apt 1204, Koramangala',
      'lat': 12.9716,
      'lng': 77.5946,
      'isDefault': true,
    });

    expect(model.label, 'Home');
    expect(model.lat, 12.9716);
    expect(model.isDefault, isTrue);
  });
}
