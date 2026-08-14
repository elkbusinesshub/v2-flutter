import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/booking_models.dart';
import 'package:elk/data/models/payment_models.dart';
import 'package:elk/data/repositories/booking_repository.dart';
import 'package:elk/data/repositories/payment_repository.dart';
import 'package:elk/features/booking/bloc/booking_bloc.dart';

const _details = BookingDetailsModel(
  serviceId: 'svc-1',
  serviceName: 'Deep Home Cleaning',
  dates: [DateSlotModel(day: 28, weekday: 'Tue')],
  timeSlots: [TimeSlotModel(time: '10:00', available: true)],
  address: '',
  pricing: PriceBreakdownModel(
    serviceFee: 85,
    promoCode: null,
    promoDiscount: 0,
    total: 85,
  ),
);

const _methods = [
  PaymentMethodModel(id: 'wallet', icon: '💳', label: 'ELK Wallet', subLabel: 'Balance: ₹0', colorHex: 0xffe0f7f5),
  PaymentMethodModel(id: 'cash', icon: '💵', label: 'Cash on Delivery', subLabel: 'Pay at service completion', colorHex: 0xfffef3c7),
];

const _confirmation = BookingConfirmationModel(
  bookingReference: '#ELK-2026-12345',
  serviceName: 'Deep Home Cleaning',
  dateTimeLabel: 'Tue 28, 10:00',
  providerName: 'Royal Shine ✓',
  amountPaid: 85,
);

class _FakeBookingRepository implements BookingRepository {
  Object? detailsError;
  Object? confirmError;
  String? lastAddress;
  double? lastLat;
  double? lastLng;
  BookingDetailsModel details = _details;

  @override
  Future<BookingDetailsModel> getBookingDetails(String serviceId) async {
    if (detailsError != null) throw detailsError!;
    return details;
  }

  @override
  Future<BookingConfirmationModel> confirmBooking({
    required String serviceId,
    required int day,
    required String time,
    required String address,
    double? lat,
    double? lng,
  }) async {
    lastAddress = address;
    lastLat = lat;
    lastLng = lng;
    if (confirmError != null) throw confirmError!;
    return _confirmation;
  }

  // Not part of the booking flow — covered by my_bookings_cubit_test.dart.
  @override
  Future<List<BookingListItemModel>> getBookings() => throw UnimplementedError();

  @override
  Future<void> cancelBooking(String bookingId, {String vertical = 'services'}) =>
      throw UnimplementedError();
}

class _FakePaymentRepository implements PaymentRepository {
  Object? payError;
  String? lastMethodId;

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async => _methods;

  @override
  Future<String> pay({
    required String methodId,
    required double amount,
    String? promoCode,
  }) async {
    lastMethodId = methodId;
    if (payError != null) throw payError!;
    return '#ELK-2026-12345';
  }
}

void main() {
  late _FakeBookingRepository bookingRepository;
  late _FakePaymentRepository paymentRepository;

  Future<BookingBloc> buildBloc({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return BookingBloc(bookingRepository, paymentRepository, preferences);
  }

  /// Drives the bloc to the payment step with date/time/address selected.
  Future<void> reachPayment(BookingBloc bloc) async {
    bloc
      ..add(const BookingDetailsRequested('svc-1'))
      ..add(const BookingDateSelected(DateSlotModel(day: 28, weekday: 'Tue')))
      ..add(const BookingTimeSelected(TimeSlotModel(time: '10:00', available: true)))
      ..add(const BookingAddressSelected(
        'Marina Walk, Tower 3',
        lat: 25.0785,
        lng: 55.1403,
      ))
      ..add(const ProceedToPaymentRequested());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.step == BookingStep.payment)),
    );
  }

  setUp(() {
    bookingRepository = _FakeBookingRepository();
    paymentRepository = _FakePaymentRepository();
  });

  test('loads booking options', () async {
    final bloc = await buildBloc()
      ..add(const BookingDetailsRequested('svc-1'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>(
        (s) => s.status == BookingStatus.ready && s.details == _details,
      )),
    );
  });

  test('emits guest status without calling the API in guest mode', () async {
    bookingRepository.detailsError = StateError('must not be called');
    final bloc = await buildBloc(prefs: {'is_guest': true})
      ..add(const BookingDetailsRequested('svc-1'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.status == BookingStatus.guest)),
    );
  });

  test('cannot proceed to payment without an address', () async {
    final bloc = await buildBloc()
      ..add(const BookingDetailsRequested('svc-1'))
      ..add(const BookingDateSelected(DateSlotModel(day: 28, weekday: 'Tue')))
      ..add(const BookingTimeSelected(TimeSlotModel(time: '10:00', available: true)));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.selectedTime != null)),
    );
    expect(bloc.state.canProceedToPayment, isFalse);

    bloc.add(const BookingAddressSelected('Marina Walk, Tower 3'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.canProceedToPayment)),
    );
  });

  test('pays and books with the selected address', () async {
    final bloc = await buildBloc();
    await reachPayment(bloc);
    expect(bloc.state.selectedMethodId, 'wallet');

    bloc
      ..add(const PaymentMethodSelected('cash'))
      ..add(const PaymentSubmitted());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>(
        (s) => s.step == BookingStep.confirmed && s.confirmation == _confirmation,
      )),
    );
    expect(paymentRepository.lastMethodId, 'cash');
    expect(bookingRepository.lastAddress, 'Marina Walk, Tower 3');
    // Sent so the tracking screen can put the job on a map; the booking used
    // to carry the text alone.
    expect(bookingRepository.lastLat, 25.0785);
    expect(bookingRepository.lastLng, 55.1403);
  });

  test('books a hand-typed address with no coordinates', () async {
    final bloc = await buildBloc();
    bloc
      ..add(const BookingDetailsRequested('svc-1'))
      ..add(const BookingDateSelected(DateSlotModel(day: 28, weekday: 'Tue')))
      ..add(const BookingTimeSelected(TimeSlotModel(time: '10:00', available: true)))
      ..add(const BookingAddressSelected('Behind the old post office'))
      ..add(const ProceedToPaymentRequested());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.step == BookingStep.payment)),
    );

    bloc.add(const PaymentSubmitted());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>((s) => s.step == BookingStep.confirmed)),
    );

    // No pin is better than a guessed one — the booking still goes through.
    expect(bookingRepository.lastAddress, 'Behind the old post office');
    expect(bookingRepository.lastLat, isNull);
    expect(bookingRepository.lastLng, isNull);
  });

  test('surfaces a friendly error when the charge fails', () async {
    paymentRepository.payError = const ApiException(
      ApiErrorType.validation,
      'Insufficient wallet balance',
    );
    final bloc = await buildBloc();
    await reachPayment(bloc);
    bloc.add(const PaymentSubmitted());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>(
        (s) =>
            s.status == BookingStatus.error &&
            s.errorMessage == 'Insufficient wallet balance',
      )),
    );
    expect(bloc.state.step, BookingStep.payment);
  });

  test('surfaces a friendly error when the details load fails', () async {
    bookingRepository.detailsError = const ApiException(
      ApiErrorType.network,
      'No internet connection. Please check your network and try again.',
    );
    final bloc = await buildBloc()
      ..add(const BookingDetailsRequested('svc-1'));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<BookingState>(
        (s) => s.status == BookingStatus.error && s.errorMessage!.contains('internet'),
      )),
    );
  });
}
