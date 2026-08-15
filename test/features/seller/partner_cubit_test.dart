import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:elk/core/api/dispatch_socket.dart';
import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/data/models/dispatch_models.dart';
import 'package:elk/data/repositories/dispatch_repository.dart';
import 'package:elk/data/repositories/porter_repository.dart';
import 'package:elk/data/repositories/ride_repository.dart';
import 'package:elk/features/seller/cubit/partner_cubit.dart';

DriverProfileModel _profile({
  DriverService service = DriverService.ride,
  bool isOnline = false,
}) =>
    DriverProfileModel(
      id: 'dp-1',
      service: service,
      vehicleSlug: 'auto',
      vehicleLabel: 'Bajaj RE · Yellow',
      plateNumber: 'KA05AB1234',
      isOnline: isOnline,
    );

JobOfferModel _offer({
  String bookingId = 'b-1',
  DriverService service = DriverService.ride,
}) =>
    JobOfferModel(
      bookingId: bookingId,
      service: service,
      code: 'ELK-TEST',
      pickupAddress: 'Koramangala',
      dropAddress: 'MG Road',
      fare: 80,
      distanceKm: 8.2,
      pickupDistanceKm: 0.4,
      expiresInSeconds: 60,
    );

class _FakeDispatch implements DispatchRepository {
  List<DriverProfileModel> profiles = [];
  Object? error;

  @override
  Future<List<DriverProfileModel>> myProfiles() async {
    if (error != null) throw error!;
    return profiles;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeRides implements RideRepository {
  PartnerJob? active;
  Object? acceptError;
  final List<String> accepted = [];

  @override
  Future<void> acceptRide(String bookingId) async {
    if (acceptError != null) throw acceptError!;
    accepted.add(bookingId);
  }

  @override
  Future<PartnerJob?> driverActiveTrip() async => active;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakePorter implements PorterRepository {
  @override
  Future<PartnerJob?> driverActiveJob() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A socket that never connects — the cubit must work over REST regardless,
/// because realtime is a convenience and not the source of truth.
class _FakeSocket implements DispatchSocket {
  final _offers = StreamController<JobOfferModel>.broadcast();
  final _closed = StreamController<String>.broadcast();

  @override
  Future<void> connect() async {}

  @override
  Stream<JobOfferModel> get offers => _offers.stream;

  @override
  Stream<String> get closedOffers => _closed.stream;

  void push(JobOfferModel offer) => _offers.add(offer);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeDispatch dispatch;
  late _FakeRides rides;
  late _FakePorter porter;
  late _FakeSocket socket;

  PartnerCubit build() => PartnerCubit(dispatch, rides, porter, socket);

  setUp(() {
    dispatch = _FakeDispatch();
    rides = _FakeRides();
    porter = _FakePorter();
    socket = _FakeSocket();
  });

  test('a partner with no vehicle on file is asked to register', () async {
    final cubit = build();

    await cubit.load();

    expect(cubit.state.status, PartnerStatus.ready);
    expect(cubit.state.isRegistered, isFalse);
    expect(cubit.state.isOnline, isFalse);
  });

  test('surfaces a failed load rather than showing an empty panel', () async {
    dispatch.error = const ApiException(ApiErrorType.network, 'offline');
    final cubit = build();

    await cubit.load();

    expect(cubit.state.status, PartnerStatus.error);
  });

  test('reads duty state from the profile for the selected product', () async {
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();

    await cubit.load();

    expect(cubit.state.isRegistered, isTrue);
    expect(cubit.state.isOnline, isTrue);
  });

  test('a partner registered for rides is not online for deliveries', () async {
    // Duty is per product: driving passengers says nothing about whether
    // they are also out collecting parcels.
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();
    await cubit.load();

    await cubit.selectService(DriverService.porter);

    expect(cubit.state.isRegistered, isFalse);
    expect(cubit.state.isOnline, isFalse);
  });

  test('an offer for the other product is ignored', () async {
    // A driver working rides must not be handed parcel jobs.
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();
    await cubit.load();

    socket.push(_offer(service: DriverService.porter));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.offers, isEmpty);
  });

  test('an offer for the selected product reaches the partner', () async {
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();
    await cubit.load();

    socket.push(_offer());
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.offers.single.bookingId, 'b-1');
  });

  test('a job somebody else took is dropped from the list', () async {
    // Whoever accepts first wins, so losing is normal — and leaving the card
    // on screen would have the partner tapping at work that is gone.
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();
    await cubit.load();
    socket.push(_offer());
    await Future<void>.delayed(Duration.zero);
    rides.acceptError = const ApiException(ApiErrorType.server, 'Another partner accepted first');

    final error = await cubit.accept(_offer());

    expect(error, isNotNull);
    expect(cubit.state.offers, isEmpty);
    expect(cubit.state.acceptingId, isNull);
  });

  test('accepting clears the queue and picks up the job', () async {
    dispatch.profiles = [_profile(isOnline: true)];
    rides.active = const PartnerJob(
      id: 'b-1',
      code: 'ELK-TEST',
      status: 'confirmed',
      pickupAddress: 'Koramangala',
      dropAddress: 'MG Road',
      fare: 80,
      otpCode: '4471',
    );
    final cubit = build();
    await cubit.load();
    socket.push(_offer());
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.accept(_offer());

    expect(error, isNull);
    expect(rides.accepted, ['b-1']);
    // The other offers go: a partner on a job is not taking another.
    expect(cubit.state.offers, isEmpty);
    expect(cubit.state.activeJob?.code, 'ELK-TEST');
  });

  test('declining removes only that offer', () async {
    dispatch.profiles = [_profile(isOnline: true)];
    final cubit = build();
    await cubit.load();
    socket.push(_offer(bookingId: 'b-1'));
    socket.push(_offer(bookingId: 'b-2'));
    await Future<void>.delayed(Duration.zero);

    cubit.decline('b-1');

    expect(cubit.state.offers.map((o) => o.bookingId), ['b-2']);
  });

  test('a job in hand is restored when the app reopens', () async {
    // A partner who closed the app mid-trip must land back on it, not on an
    // empty screen with a customer waiting.
    dispatch.profiles = [_profile(isOnline: true)];
    rides.active = const PartnerJob(
      id: 'b-9',
      code: 'ELK-LIVE',
      status: 'in_progress',
      pickupAddress: 'Koramangala',
      dropAddress: 'MG Road',
      fare: 80,
    );
    final cubit = build();

    await cubit.load();

    expect(cubit.state.activeJob?.code, 'ELK-LIVE');
    expect(cubit.state.activeJob!.isUnderWay, isTrue);
  });
}
