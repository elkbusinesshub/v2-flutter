import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/models/booking_models.dart';
import 'package:elk/data/models/payment_models.dart';
import 'package:elk/data/repositories/payment_repository.dart';
import 'package:elk/features/booking/bloc/booking_bloc.dart';

import '../../support/fake_marketplace_repository.dart';

const _methods = [
  PaymentMethodModel(id: 'wallet', icon: '💳', label: 'ELK Wallet', subLabel: 'Balance: ₹0', colorHex: 0xffe0f7f5),
  PaymentMethodModel(id: 'cash', icon: '💵', label: 'Cash on Delivery', subLabel: 'Pay at service completion', colorHex: 0xfffef3c7),
];

class _FakeMarketplace extends FakeMarketplaceRepositoryBase {
  Object? detailsError;
  Object? confirmError;
  String? lastAddress;
  DateTime? lastScheduledAt;
  double? lastFees;

  AdModel ad = AdModel.fromJson({
    'id': 'svc-1',
    'title': 'Deep Home Cleaning',
    'sellerName': 'Royal Shine',
    'categorySlug': 'cleaning',
    'price': 85,
    'location': 'Koramangala, Bengaluru',
  });

  @override
  Future<AdModel> getAd(String id) async {
    if (detailsError != null) throw detailsError!;
    return ad;
  }

  @override
  Future<AdOrderModel> placeOrder(
    String adId, {
    required String addressText,
    required String contactPhone,
    double? lat,
    double? lng,
    int quantity = 1,
    bool isEnquiry = false,
    DateTime? scheduledAt,
    DateTime? endAt,
    int? durationMonths,
    double? depositAmount,
    double? feesAmount,
    double? taxAmount,
    String? note,
  }) async {
    lastAddress = addressText;
    lastScheduledAt = scheduledAt;
    lastFees = feesAmount;
    if (confirmError != null) throw confirmError!;
    return AdOrderModel.fromJson({
      'id': 'o-1',
      'code': 'ELK-A-12345',
      'adId': adId,
      'status': 'NEW',
      'amount': 85,
      'serviceName': 'Deep Home Cleaning',
    });
  }
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
  late _FakeMarketplace bookingRepository;
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
    bookingRepository = _FakeMarketplace();
    paymentRepository = _FakePaymentRepository();
  });

  test('loads booking options', () async {
    final bloc = await buildBloc()
      ..add(const BookingDetailsRequested('svc-1'));
    await expectLater(
      bloc.stream,
      // The dates and windows are generated from today, so the details cannot
      // be compared against a fixed fixture any more.
      emitsThrough(predicate<BookingState>(
        (s) =>
            s.status == BookingStatus.ready &&
            s.details?.serviceName == 'Deep Home Cleaning' &&
            s.details!.dates.length == 7 &&
            s.details!.timeSlots.isNotEmpty &&
            // The buyer picks where the job happens; the seller's locality is
            // not an answer to that.
            s.details!.address.isEmpty &&
            s.details!.pricing.total == 95,
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
        (s) =>
            s.step == BookingStep.confirmed &&
            s.confirmation?.bookingReference == 'ELK-A-12345' &&
            s.confirmation?.providerName == 'Royal Shine',
      )),
    );
    expect(paymentRepository.lastMethodId, 'cash');
    expect(bookingRepository.lastAddress, 'Marina Walk, Tower 3');
    // The chosen day and window reach the order as one instant.
    expect(bookingRepository.lastScheduledAt!.day, 28);
    expect(bookingRepository.lastScheduledAt!.hour, 10);
    // The fee the screen showed, so the order and the receipt agree.
    expect(bookingRepository.lastFees, 10);
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
    //
    // The coordinates the picker resolves no longer reach the order: an
    // ad_order stores address text only, so the map on the tracking screen
    // has nothing to centre on. Recorded as a known loss rather than adding
    // columns nothing reads yet.
    expect(bookingRepository.lastAddress, 'Behind the old post office');
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
