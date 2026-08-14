import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/porter_models.dart';
import 'package:elk/data/repositories/porter_repository.dart';
import 'package:elk/core/location/trip_point.dart';
import 'package:elk/features/porter/cubit/porter_cubit.dart';

const _bike = PorterVehicleModel(
  id: 'bike',
  emoji: '🏍️',
  name: 'Bike',
  capacity: 'Up to 5 kg',
  iconKey: 'veh_bike',
  etaMinutes: 12,
  baseFare: 35,
  badge: 'FASTEST',
);

const _truck = PorterVehicleModel(
  id: 'truck',
  emoji: '🚚',
  name: 'Truck',
  capacity: 'Up to 3 Ton',
  iconKey: 'veh_truck',
  etaMinutes: 25,
  baseFare: 180,
);

const _page = PorterPageModel(
  vehicles: [_bike, _truck],
  route: PorterRouteModel(
    pickupLabel: 'Pickup',
    pickupAddress: 'Indiranagar, Block C',
    dropLabel: 'Drop',
    dropAddress: 'MG Road, Tower 4',
    packageType: 'Electronics',
    weight: '2.5 kg',
    estimatedFare: 35,
    distanceKm: 4.2,
    etaMinutes: 12,
  ),
  addons: [
    PorterAddonModel(id: 'helper', label: 'Loading helper', price: 30),
    PorterAddonModel(id: 'insure', label: 'Insurance', price: 10),
  ],
  pickupWindows: ['9:00 – 10:00', '11:00 – 12:00'],
  serviceFee: 3.5,
  vatRate: 0.05,
);

class _FakePorterRepository implements PorterRepository {
  Object? error;
  Object? bookingError;
  Map<String, dynamic>? lastQuote;
  Map<String, dynamic>? lastBooking;

  @override
  Future<PorterPageModel> getPorterOptions() async {
    if (error != null) throw error!;
    return _page;
  }

  @override
  Future<PorterBreakdown> quote({
    required String vehicleId,
    List<String> addons = const [],
  }) async {
    lastQuote = {'vehicleId': vehicleId, 'addons': addons};
    if (error != null) throw error!;
    final base = vehicleId == 'truck' ? 180.0 : 35.0;
    final addonsTotal = addons.fold(0.0, (sum, a) => sum + (a == 'helper' ? 30 : 10));
    final vat = (base + addonsTotal + 3.5) * 0.05;
    return PorterBreakdown(
      baseFare: base,
      addonsTotal: addonsTotal,
      serviceFee: 3.5,
      vatAmount: vat,
      totalAmount: base + addonsTotal + 3.5 + vat,
    );
  }

  @override
  Future<PorterBookingModel> createBooking({
    required String vehicleId,
    required String pickupAddress,
    required String dropAddress,
    required String paymentMethod,
    List<String> addons = const [],
    String? packageType,
    String? weightLabel,
    String? scheduledDate,
    String? pickupWindow,
  }) async {
    lastBooking = {
      'vehicleId': vehicleId,
      'addons': addons,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'paymentMethod': paymentMethod,
      'scheduledDate': scheduledDate,
      'pickupWindow': pickupWindow,
    };
    if (bookingError != null) throw bookingError!;
    return PorterBookingModel(
      id: 'pb-1',
      code: 'ELK-4821-QT',
      status: 'confirmed',
      vehicle: _bike,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      pickupWindow: pickupWindow,
      breakdown: const PorterBreakdown(
        baseFare: 35,
        addonsTotal: 30,
        serviceFee: 3.5,
        vatAmount: 3.43,
        totalAmount: 71.93,
      ),
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<List<PorterBookingModel>> getBookings() async => const [];

  @override
  Future<void> cancelBooking(String bookingId) async {}
}

/// Picked locations carry coordinates now, so the map can draw the route; the
/// booking payload still sends only the address.
const _marina = TripPoint(address: 'Marina Gate 3', lat: 25.0785, lng: 55.1403);
const _burjViews = TripPoint(address: 'Burj Views', lat: 25.1908, lng: 55.2738);

void main() {
  late _FakePorterRepository repository;

  Future<PorterCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return PorterCubit(repository, preferences);
  }

  setUp(() => repository = _FakePorterRepository());

  test('loads options, preselects the first vehicle and quotes it', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    expect(cubit.state.status, PorterStatus.loaded);
    expect(cubit.state.selectedVehicleId, 'bike');
    expect(cubit.state.page!.pickupWindows, hasLength(2));
    // Options load triggers an immediate quote.
    expect(repository.lastQuote!['vehicleId'], 'bike');
    expect(cubit.state.breakdown!.totalAmount, closeTo(40.43, 0.01));
  });

  test('guest mode short-circuits', () async {
    repository.error = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadOptions();
    expect(cubit.state.status, PorterStatus.guest);
  });

  test('changing vehicle re-quotes server-side', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    await cubit.selectVehicle('truck');
    expect(repository.lastQuote!['vehicleId'], 'truck');
    expect(cubit.state.breakdown!.baseFare, 180);
  });

  test('toggling an add-on re-quotes and updates the fare', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    await cubit.toggleAddon('helper');
    expect(cubit.state.selectedAddonIds, {'helper'});
    expect(repository.lastQuote!['addons'], ['helper']);
    expect(cubit.state.addonsTotal, 30);
    expect(cubit.state.fareBeforeFees, 65);

    await cubit.toggleAddon('helper');
    expect(cubit.state.selectedAddonIds, isEmpty);
    expect(cubit.state.addonsTotal, 0);
  });

  test('books "now" without schedule fields', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina, drop: _burjViews);
    final ok = await cubit.bookPorter();
    expect(ok, isTrue);
    expect(repository.lastBooking!['pickupAddress'], 'Marina Gate 3');
    expect(repository.lastBooking!['scheduledDate'], isNull);
    expect(repository.lastBooking!['pickupWindow'], isNull);
    expect(cubit.state.status, PorterStatus.booked);
    expect(cubit.state.bookingReference, 'ELK-4821-QT');
  });

  test('books a scheduled pickup and can revert to "now"', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina, drop: _burjViews);
    cubit.setSchedule(date: '2026-08-02', window: '11:00 – 12:00');
    expect(cubit.state.isScheduled, isTrue);

    await cubit.bookPorter();
    expect(repository.lastBooking!['scheduledDate'], '2026-08-02');
    expect(repository.lastBooking!['pickupWindow'], '11:00 – 12:00');

    cubit.clearSchedule();
    expect(cubit.state.isScheduled, isFalse);
    expect(cubit.state.scheduledDate, isNull);
    // Clearing keeps the rest of the selection intact.
    expect(cubit.state.selectedVehicleId, 'bike');
  });

  test('sends the selected payment method', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina, drop: _burjViews);
    cubit.selectPaymentMethod('cash');
    await cubit.bookPorter();
    expect(repository.lastBooking!['paymentMethod'], 'cash');
  });

  test('surfaces booking failures without losing the selection', () async {
    repository.bookingError = const ApiException(
      ApiErrorType.validation,
      'pickupWindow must be one of the offered windows',
    );
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina, drop: _burjViews);
    final ok = await cubit.bookPorter();
    expect(ok, isFalse);
    expect(cubit.state.bookingError, contains('pickupWindow'));
    expect(cubit.state.status, PorterStatus.loaded);
    expect(cubit.state.selectedVehicleId, 'bike');
  });

  test('refuses to book before the route is set', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();

    // The defaults used to be 'Indiranagar, Block C' → 'MG Road, Tower 4',
    // which were submitted verbatim for anyone who never opened the picker.
    expect(cubit.state.pickupAddress, isEmpty);
    expect(cubit.state.dropAddress, isEmpty);
    expect(cubit.state.hasRoute, isFalse);

    expect(await cubit.bookPorter(), isFalse);
    expect(repository.lastBooking, isNull);
    expect(cubit.state.bookingError, isNotNull);
  });

  test('keeps the coordinates the picker returned, but posts only the address',
      () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina, drop: _burjViews);

    // The map needs the coordinates; the porter API takes text.
    expect(cubit.state.pickup.hasCoordinates, isTrue);
    expect(cubit.state.drop.lat, 25.1908);

    await cubit.bookPorter();
    expect(repository.lastBooking!['pickupAddress'], 'Marina Gate 3');
    expect(repository.lastBooking!.containsKey('pickupLat'), isFalse);
  });

  test('a half-set route is still refused', () async {
    final cubit = await buildCubit();
    await cubit.loadOptions();
    cubit.setRoute(pickup: _marina);

    expect(cubit.state.hasRoute, isFalse);
    expect(await cubit.bookPorter(), isFalse);
    expect(repository.lastBooking, isNull);
  });

  test('surfaces a friendly error when options fail', () async {
    repository.error = const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.loadOptions();
    expect(cubit.state.status, PorterStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });
}
