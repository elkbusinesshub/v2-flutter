import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/booking_models.dart';
import 'package:elk/data/repositories/booking_repository.dart';
import 'package:elk/features/bookings/cubit/my_bookings_cubit.dart';

BookingListItemModel _booking({
  required String id,
  required String status,
  DateTime? scheduledAt,
  double total = 85,
  String vertical = 'marketplace',
}) =>
    BookingListItemModel(
      id: id,
      vertical: vertical,
      reference: 'ELK-2026-$id',
      serviceName: 'Home Cleaning',
      serviceIcon: '🏠',
      providerName: 'Royal Shine',
      status: status,
      scheduledAt: scheduledAt ?? DateTime(2026, 8, 2, 10),
      addressText: 'Tower 3, Apt 1204',
      total: total,
    );

class _FakeBookingRepository implements BookingRepository {
  String? cancelledVertical;
  _FakeBookingRepository(this.bookings);

  List<BookingListItemModel> bookings;
  Object? error;
  Object? cancelError;
  final List<String> cancelled = [];

  @override
  Future<List<BookingListItemModel>> getBookings() async {
    if (error != null) throw error!;
    return bookings;
  }

  @override
  Future<void> cancelBooking(String bookingId, {String vertical = 'marketplace'}) async {
    cancelledVertical = vertical;
    if (cancelError != null) throw cancelError!;
    cancelled.add(bookingId);
    bookings = [
      for (final b in bookings)
        if (b.id == bookingId)
          _booking(id: b.id, status: 'cancelled', total: b.total)
        else
          b,
    ];
  }
}

void main() {
  // dateLabel/timeLabel format through intl in the active locale, which needs
  // the symbol data main() loads at startup.
  setUpAll(initializeDateFormatting);

  Future<MyBookingsCubit> buildCubit(
    _FakeBookingRepository repository, {
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return MyBookingsCubit(repository, preferences);
  }

  test('loads bookings and buckets them into tabs', () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'confirmed'),
      _booking(id: '2', status: 'completed'),
      _booking(id: '3', status: 'cancelled'),
      _booking(id: '4', status: 'confirmed'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    expect(cubit.state.status, MyBookingsStatus.loaded);
    expect(cubit.state.countFor('upcoming'), 2);
    expect(cubit.state.countFor('completed'), 1);
    expect(cubit.state.countFor('cancelled'), 1);
    // The default tab is Upcoming.
    expect(cubit.state.visible.map((b) => b.id), ['1', '4']);
  });

  test('switching tabs changes what is visible without refetching', () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'confirmed'),
      _booking(id: '2', status: 'completed'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    cubit.selectTab('completed');
    expect(cubit.state.visible.single.id, '2');
    expect(cubit.state.status, MyBookingsStatus.loaded);
  });

  test('guest mode short-circuits before hitting the API', () async {
    final repository = _FakeBookingRepository([])
      ..error = StateError('must not be called');
    final cubit = await buildCubit(repository, values: {'is_guest': true});
    await cubit.load();
    expect(cubit.state.status, MyBookingsStatus.guest);
  });

  test('cancelling routes to the vertical that owns the booking', () async {
    // Porter and rides each enforce their own cancellation rules, so a porter
    // job cancelled through the marketplace endpoint would 404.
    final repository = _FakeBookingRepository([
      _booking(id: 'pt-1', status: 'confirmed', vertical: 'porter'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    await cubit.cancelBooking('pt-1');
    expect(repository.cancelledVertical, 'porter');
  });

  test('an unknown booking id falls back to the listing-order endpoint', () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'confirmed'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    await cubit.cancelBooking('does-not-exist');
    expect(repository.cancelledVertical, 'marketplace');
  });

  test('cancelling reloads so the booking moves to the Cancelled tab', () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'confirmed'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    final message = await cubit.cancelBooking('1');
    expect(message, 'Booking cancelled');
    expect(repository.cancelled, ['1']);
    expect(cubit.state.bookings.single.isCancelled, isTrue);
    expect(cubit.state.countFor('cancelled'), 1);
    // The in-flight marker is always cleared.
    expect(cubit.state.cancellingId, isNull);
  });

  test('a rejected cancel returns the server message and keeps the booking',
      () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'confirmed'),
    ])..cancelError = const ApiException(
        // A 409 keeps the backend's own message — see ApiException.fromStatus.
        ApiErrorType.unknown,
        'Only upcoming confirmed bookings can be cancelled',
      );
    final cubit = await buildCubit(repository);
    await cubit.load();

    final message = await cubit.cancelBooking('1');
    expect(message, contains('confirmed bookings can be cancelled'));
    expect(cubit.state.bookings.single.isUpcoming, isTrue);
    expect(cubit.state.cancellingId, isNull);
  });

  test('markRated remembers the booking for this session', () async {
    final repository = _FakeBookingRepository([
      _booking(id: '1', status: 'completed'),
    ]);
    final cubit = await buildCubit(repository);
    await cubit.load();

    expect(cubit.state.ratedIds, isEmpty);
    cubit.markRated('1');
    expect(cubit.state.ratedIds, {'1'});
  });

  test('surfaces a friendly error when the list fails', () async {
    final repository = _FakeBookingRepository([])
      ..error = const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit(repository);
    await cubit.load();

    expect(cubit.state.status, MyBookingsStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });

  group('BookingListItemModel', () {
    test('parses the backend payload and lower-cases the status', () {
      final model = BookingListItemModel.fromJson({
        'id': 'b1',
        'reference': 'ELK-2026-48213',
        'serviceName': 'AC Repair',
        'serviceIcon': '🔧',
        'providerName': 'Express Fix',
        'status': 'CONFIRMED',
        'scheduledAt': '2026-08-02T10:00:00.000Z',
        'addressText': 'Villa 22',
        'total': 150,
      });

      expect(model.status, 'confirmed');
      expect(model.isUpcoming, isTrue);
      expect(model.total, 150);
      expect(model.serviceIcon, '🔧');
    });

    test('labels dates relative to today', () {
      final now = DateTime(2026, 8, 2, 9);
      String labelFor(DateTime at) =>
          _booking(id: '1', status: 'confirmed', scheduledAt: at).dateLabel(now: now);

      expect(labelFor(DateTime(2026, 8, 2, 14)), 'Today');
      expect(labelFor(DateTime(2026, 8, 3, 14)), 'Tomorrow');
      expect(labelFor(DateTime(2026, 8, 8, 14)), 'Sat 8 Aug');
    });

    test('formats times in 12-hour clock', () {
      String timeAt(int hour, int minute) => _booking(
            id: '1',
            status: 'confirmed',
            scheduledAt: DateTime(2026, 8, 2, hour, minute),
          ).timeLabel;

      expect(timeAt(0, 30), '12:30 AM');
      expect(timeAt(9, 0), '9:00 AM');
      expect(timeAt(12, 0), '12:00 PM');
      expect(timeAt(18, 5), '6:05 PM');
    });
  });
}
