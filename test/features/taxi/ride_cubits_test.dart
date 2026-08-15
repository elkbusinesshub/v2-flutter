import 'package:flutter_test/flutter_test.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/data/models/ride_models.dart';
import 'package:elk/data/models/dispatch_models.dart';
import 'package:elk/data/repositories/dispatch_repository.dart';
import 'package:elk/data/repositories/ride_repository.dart';
import 'package:elk/features/taxi/cubit/ride_booking_cubit.dart';

const _auto = RideTypeModel(
  id: 'auto',
  emoji: '🛺',
  name: 'Auto',
  price: 8,
  iconKey: 'car_auto',
  seats: 3,
  etaMinutes: 4,
  cancellationFee: 6,
  badge: 'FASTER',
);

const _economy = RideTypeModel(
  id: 'economy',
  emoji: '🚗',
  name: 'Economy',
  price: 15,
  iconKey: 'car_sedan',
  seats: 4,
  etaMinutes: 5,
  cancellationFee: 10,
);

const _estimate = TaxiLocationModel(
  pickup: 'Indiranagar · Gate 3',
  drop: 'MG Road, Brigade Towers',
  etaMinutes: 14,
  distanceKm: 8.2,
);

RideBookingModel _bookingWith({
  String status = 'confirmed',
  String? otp = '8264',
  DateTime? startedAt,
  DateTime? completedAt,
  double tip = 0,
  int? stars,
}) =>
    RideBookingModel(
      id: 'ride-1',
      code: 'ELK-7QK2M9P',
      status: status,
      rideType: _auto,
      pickupAddress: 'Indiranagar · Gate 3',
      dropAddress: 'MG Road · Brigade Towers',
      distanceKm: 8.2,
      etaMinutes: 14,
      driverName: 'Farhan Ahmed',
      vehicle: 'Toyota Corolla · White',
      plateNumber: 'DXB · B 22417',
      otpCode: otp,
      fare: 8,
      paymentMethod: 'card',
      tipAmount: tip,
      ratingStars: stars,
      startedAt: startedAt,
      completedAt: completedAt,
    );

/// Nobody on duty by default — the map is empty unless a test says otherwise.
class _FakeDispatchRepository implements DispatchRepository {
  _FakeDispatchRepository([this.vehicles = const []]);

  final List<NearbyVehicleModel> vehicles;
  Object? error;

  @override
  Future<List<NearbyVehicleModel>> nearby({
    required DriverService service,
    required double lat,
    required double lng,
    String? vehicleSlug,
  }) async {
    if (error != null) throw error!;
    return vehicles;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeRideRepository implements RideRepository {
  /// The partner-side calls belong to the seller panel, not these cubits.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  Object? error;
  List<RideTypeModel> rideTypes = [_auto, _economy];
  Map<String, dynamic>? lastBooking;
  String? lastOtp;
  Map<String, dynamic>? lastRating;
  bool cancelled = false;

  @override
  Future<List<RideTypeModel>> getRideTypes() async {
    if (error != null) throw error!;
    return rideTypes;
  }

  @override
  Future<TaxiLocationModel> getCurrentTrip() async {
    if (error != null) throw error!;
    return _estimate;
  }

  @override
  Future<RideBookingModel> createBooking({
    required String rideTypeId,
    required String pickupAddress,
    required String dropAddress,
    required String paymentMethod,
    double? pickupLat,
    double? pickupLng,
  }) async {
    lastBooking = {
      'rideTypeId': rideTypeId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'paymentMethod': paymentMethod,
    };
    if (error != null) throw error!;
    return _bookingWith();
  }

  @override
  Future<List<RideBookingModel>> getBookings() async => [_bookingWith()];

  @override
  Future<RideBookingModel> startRide(String bookingId, String otpCode) async {
    lastOtp = otpCode;
    if (error != null) throw error!;
    return _bookingWith(
      status: 'in_progress',
      otp: null,
      startedAt: DateTime.utc(2026, 7, 28, 9),
    );
  }

  @override
  Future<RideBookingModel> completeRide(String bookingId) async {
    if (error != null) throw error!;
    return _bookingWith(
      status: 'completed',
      otp: null,
      startedAt: DateTime.utc(2026, 7, 28, 9),
      completedAt: DateTime.utc(2026, 7, 28, 9, 20),
    );
  }

  @override
  Future<void> cancelRide(String bookingId) async {
    if (error != null) throw error!;
    cancelled = true;
  }

  @override
  Future<RideBookingModel> rateRide(
    String bookingId, {
    required int stars,
    int tip = 0,
  }) async {
    lastRating = {'stars': stars, 'tip': tip};
    if (error != null) throw error!;
    return _bookingWith(
      status: 'completed',
      otp: null,
      completedAt: DateTime.utc(2026, 7, 28, 9, 20),
      tip: tip.toDouble(),
      stars: stars,
    );
  }
}

void main() {
  late _FakeRideRepository repository;

  /// Drives a cubit to the point where a ride has been booked.
  Future<RideBookingCubit> bookedCubit() async {
    final cubit = RideBookingCubit(repository, _FakeDispatchRepository());
    await cubit.loadOptions();
    await cubit.confirmBooking(pickupAddress: 'A', dropAddress: 'B');
    return cubit;
  }

  setUp(() => repository = _FakeRideRepository());

  group('booking flow', () {
    test('loads options and preselects the first ride class', () async {
      final cubit = RideBookingCubit(repository, _FakeDispatchRepository());
      await cubit.loadOptions();
      expect(cubit.state.optionsStatus, RideOptionsStatus.loaded);
      expect(cubit.state.selectedRideTypeId, 'auto');
      expect(cubit.state.estimate!.distanceKm, 8.2);
    });

    test('shows the vehicles actually on duty nearby', () async {
      final dispatch = _FakeDispatchRepository([
        const NearbyVehicleModel(
          vehicleSlug: 'auto',
          emoji: '🛺',
          lat: 12.9352,
          lng: 77.6245,
          distanceKm: 0.4,
          etaMinutes: 4,
        ),
      ]);
      final cubit = RideBookingCubit(repository, dispatch);

      await cubit.loadNearbyVehicles(12.936, 77.625);

      expect(cubit.state.nearbyVehicles.single.emoji, '🛺');
    });

    test('a failed nearby lookup empties the map instead of breaking it', () async {
      // The rider can still book without seeing anybody; a thrown error here
      // would take the whole screen down for a decoration.
      final dispatch = _FakeDispatchRepository()..error = StateError('offline');
      final cubit = RideBookingCubit(repository, dispatch);

      await cubit.loadNearbyVehicles(12.936, 77.625);

      expect(cubit.state.nearbyVehicles, isEmpty);
    });

    test('an empty catalogue loads rather than staying in loading', () async {
      // The screen shows a spinner until the load finishes. If an empty
      // catalogue left the status at `loading`, the taxi tab would appear to
      // hang forever instead of saying there is nothing to book.
      repository.rideTypes = [];
      final cubit = RideBookingCubit(repository, _FakeDispatchRepository());

      await cubit.loadOptions();

      expect(cubit.state.optionsStatus, RideOptionsStatus.loaded);
      expect(cubit.state.rideTypes, isEmpty);
      expect(cubit.state.selectedRideTypeId, isNull);
    });

    test('confirmBooking sends the trip and stores code + OTP', () async {
      final cubit = RideBookingCubit(repository, _FakeDispatchRepository());
      await cubit.loadOptions();
      cubit
        ..selectRideType('economy')
        ..selectPaymentMethod('wallet');
      final ok = await cubit.confirmBooking(
        pickupAddress: 'Indiranagar · Gate 3',
        dropAddress: 'MG Road · Brigade Towers',
      );
      expect(ok, isTrue);
      expect(repository.lastBooking!['rideTypeId'], 'economy');
      expect(repository.lastBooking!['paymentMethod'], 'wallet');
      expect(cubit.state.booking!.code, 'ELK-7QK2M9P');
      expect(cubit.state.booking!.otpCode, '8264');
      // The booked driver supersedes any preview.
      expect(cubit.state.driverName, 'Farhan Ahmed');
    });

    test('startRide sends the OTP and clears it once started', () async {
      final cubit = await bookedCubit();
      final ok = await cubit.startRide('8264');
      expect(ok, isTrue);
      expect(repository.lastOtp, '8264');
      expect(cubit.state.booking!.isStarted, isTrue);
      expect(cubit.state.booking!.otpCode, isNull);
    });

    test('completeRide marks the trip completed', () async {
      final cubit = await bookedCubit();
      await cubit.startRide('8264');
      final ok = await cubit.completeRide();
      expect(ok, isTrue);
      expect(cubit.state.booking!.isCompleted, isTrue);
    });

    test('rateRide posts stars and tip, updating the total', () async {
      final cubit = await bookedCubit();
      final ok = await cubit.rateRide(stars: 5, tip: 5);
      expect(ok, isTrue);
      expect(repository.lastRating, {'stars': 5, 'tip': 5});
      expect(cubit.state.booking!.ratingStars, 5);
      expect(cubit.state.booking!.totalPaid, 13);
    });

    test('cancelRide flags the booking as cancelled', () async {
      final cubit = await bookedCubit();
      final ok = await cubit.cancelRide();
      expect(ok, isTrue);
      expect(repository.cancelled, isTrue);
      expect(cubit.state.isCancelled, isTrue);
    });

    test('surfaces backend failures on booking', () async {
      final cubit = RideBookingCubit(repository, _FakeDispatchRepository());
      await cubit.loadOptions();
      repository.error = const ApiException(
        ApiErrorType.validation,
        'Unknown ride type',
      );
      final ok = await cubit.confirmBooking(pickupAddress: 'A', dropAddress: 'B');
      expect(ok, isFalse);
      expect(cubit.state.actionError, contains('Unknown ride type'));
      expect(cubit.state.isSubmitting, isFalse);
    });

    test('lifecycle actions no-op without a booking', () async {
      final cubit = RideBookingCubit(repository, _FakeDispatchRepository());
      expect(await cubit.startRide('1234'), isFalse);
      expect(await cubit.completeRide(), isFalse);
      expect(await cubit.cancelRide(), isFalse);
    });
  });
}
