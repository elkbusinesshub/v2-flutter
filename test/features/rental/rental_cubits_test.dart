import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/ad_models.dart';
import 'package:elk/features/rental/cubit/rental_booking_cubit.dart';
import 'package:elk/features/rental/cubit/rental_cubit.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(
  String id,
  String title, {
  String? subCategory,
  double price = 2400,
  int wishlistCount = 0,
  String location = 'Koramangala, Bengaluru',
  Map<String, dynamic>? attributes,
}) =>
    AdModel.fromJson({
      'id': id,
      'title': title,
      'description': 'Well kept, full tank.',
      'sellerName': 'Prime Wheels',
      'categorySlug': 'car_rental',
      'price': price,
      'location': location,
      'wishlistCount': wishlistCount,
      'attributes': {'subCategory': ?subCategory, ...?attributes},
    });

class _FakeMarketplace extends FakeMarketplaceRepositoryBase {
  List<AdModel> ads = [
    _ad('ad-1', 'Swift Dzire',
        subCategory: 'SEDAN',
        attributes: {'seats': 5, 'transmission': 'AUTOMATIC', 'fuel': 'PETROL'}),
    _ad('ad-2', 'Nissan Patrol', subCategory: 'SUV', price: 4200),
    _ad('ad-3', 'Mercedes E-Class', subCategory: 'LUXURY', price: 7900, wishlistCount: 6),
  ];
  String? requestedCategory;
  Object? error;

  final List<
      ({
        String adId,
        int quantity,
        DateTime? scheduledAt,
        DateTime? endAt,
        String address
      })> placed = [];
  Object? placeError;

  @override
  Future<List<AdModel>> listAds({String? query, String? category, int? limit}) async {
    requestedCategory = category;
    if (error != null) throw error!;
    return ads;
  }

  @override
  Future<AdModel> getAd(String id) async {
    if (error != null) throw error!;
    return ads.firstWhere((a) => a.id == id);
  }

  @override
  Future<AdOrderModel> placeOrder(
    String adId, {
    required String addressText,
    required String contactPhone,
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
    placed.add((
      adId: adId,
      quantity: quantity,
      scheduledAt: scheduledAt,
      endAt: endAt,
      address: addressText,
    ));
    if (placeError != null) throw placeError!;
    return AdOrderModel.fromJson({
      'id': 'o-1',
      'code': 'ELK-A-9KD2P',
      'adId': adId,
      'status': 'NEW',
      'amount': 2400,
      'serviceName': 'Swift Dzire',
    });
  }
}

Map<String, dynamic> _trip({
  String fulfilment = 'pickup',
  String pickup = '2026-09-01T10:00:00.000',
  String ret = '2026-09-04T10:00:00.000',
}) =>
    {
      'carId': 'ad-1',
      'rentalType': 'daily',
      'pickupAt': pickup,
      'returnAt': ret,
      'fulfilment': fulfilment,
      if (fulfilment == 'delivery') ...{
        'deliveryAddress': 'Villa 22, Koramangala',
        'deliveryNotes': 'Call on arrival',
      },
    };

void main() {
  late _FakeMarketplace marketplace;
  late AppPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_phone': '+919562461531'});
    preferences = AppPreferences(await SharedPreferences.getInstance());
    marketplace = _FakeMarketplace();
  });

  group('catalogue', () {
    late RentalCubit cubit;

    setUp(() => cubit = RentalCubit(marketplace, preferences));

    test('lists what sellers posted under car rental', () async {
      await cubit.loadCars();

      expect(marketplace.requestedCategory, 'car_rental');
      expect(cubit.state.status, RentalStatus.loaded);
      expect(cubit.state.cars.map((c) => c.name), [
        'Swift Dzire',
        'Nissan Patrol',
        'Mercedes E-Class',
      ]);
    });

    test('renders the details a seller supplied', () async {
      await cubit.loadCars();

      final car = cubit.state.cars.first;
      expect(car.seats, 5);
      expect(car.transmission, 'Automatic');
      expect(car.fuel, 'Petrol');
      expect(car.type, 'Sedan');
    });

    test('files an unlabelled listing as a sedan rather than hiding it', () async {
      marketplace.ads = [_ad('ad-9', 'Mystery Car')];

      await cubit.loadCars();

      expect(cubit.state.cars.single.type, 'Sedan');
    });

    test('a well-saved listing earns the best-deal ribbon', () async {
      // Sellers cannot set a badge, so engagement stands in for the curated
      // flag the seeded fleet carried.
      await cubit.loadCars();

      expect(cubit.state.cars.last.isBestDeal, isTrue);
      expect(cubit.state.cars.first.isBestDeal, isFalse);
    });

    test('the type filter narrows without another round trip', () async {
      await cubit.loadCars();
      marketplace.requestedCategory = null;

      cubit.selectTypeFilter('SUV');

      expect(marketplace.requestedCategory, isNull);
      expect(cubit.state.cars.map((c) => c.name), ['Nissan Patrol']);
    });

    test('guest mode short-circuits before hitting the API', () async {
      SharedPreferences.setMockInitialValues({'is_guest': true});
      cubit = RentalCubit(marketplace, AppPreferences(await SharedPreferences.getInstance()));

      await cubit.loadCars();

      expect(cubit.state.status, RentalStatus.guest);
      expect(marketplace.requestedCategory, isNull);
    });

    test('surfaces a friendly error', () async {
      marketplace.error = Exception('offline');

      await cubit.loadCars();

      expect(cubit.state.status, RentalStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('booking flow', () {
    late RentalBookingCubit cubit;

    setUp(() => cubit = RentalBookingCubit(marketplace, preferences));

    test('the pickup point is the seller, not a company branch', () async {
      await cubit.loadOptions('ad-1');

      expect(cubit.state.optionsStatus, RentalOptionsStatus.loaded);
      final branch = cubit.state.branches.single;
      expect(branch.name, 'Prime Wheels');
      expect(branch.address, 'Koramangala, Bengaluru');
      expect(cubit.state.selectedBranchId, 'ad-1');
    });

    test('offers no extras, since no seller can supply them', () async {
      await cubit.loadOptions('ad-1');

      expect(cubit.state.extras, isEmpty);
    });

    test('prices the trip from the listing rate', () async {
      await cubit.loadOptions('ad-1');

      await cubit.refreshQuote(_trip());

      final b = cubit.state.quote!.breakdown;
      expect(b.days, 3);
      expect(b.dailyRate, 2400);
      expect(b.rentalTotal, 7200);
      expect(b.deliveryFee, 0);
      expect(b.vatAmount, 360); // 5% of 7200
      expect(b.totalAmount, 7560);
    });

    test('adds the delivery fee only when the car is brought over', () async {
      await cubit.loadOptions('ad-1');

      await cubit.refreshQuote(_trip(fulfilment: 'delivery'));

      expect(cubit.state.quote!.breakdown.deliveryFee, 25);
    });

    test('charges a part day as a full day', () async {
      await cubit.loadOptions('ad-1');

      await cubit.refreshQuote(_trip(ret: '2026-09-02T14:00:00.000'));

      expect(cubit.state.quote!.breakdown.days, 2);
    });

    test('refuses a return that is not after the pickup', () async {
      await cubit.loadOptions('ad-1');

      await cubit.refreshQuote(_trip(ret: '2026-08-30T10:00:00.000'));

      expect(cubit.state.quote, isNull);
      expect(cubit.state.quoteError, isNotNull);
    });

    test('refuses every promo code rather than ignoring it silently', () async {
      // The codes lived in `rental_promos`, which no seller can write to.
      await cubit.loadOptions('ad-1');

      final message = await cubit.applyPromo('ELK10', _trip());

      expect(message, isNotNull);
      expect(cubit.state.quoteError, isNotNull);
    });

    test('books the trip window as one order', () async {
      await cubit.loadOptions('ad-1');
      await cubit.refreshQuote(_trip());

      final ok = await cubit.confirmBooking(_trip());

      expect(ok, isTrue);
      final order = marketplace.placed.single;
      expect(order.adId, 'ad-1');
      // Days, not cars — the backend charges price × quantity, and the
      // listing is priced per day.
      expect(order.quantity, 3);
      expect(order.scheduledAt, DateTime.parse('2026-09-01T10:00:00.000'));
      expect(order.endAt, DateTime.parse('2026-09-04T10:00:00.000'));
      expect(order.address, 'Koramangala, Bengaluru');
      expect(cubit.state.booking!.code, 'ELK-A-9KD2P');
    });

    test('a delivery booking carries the renter’s address', () async {
      await cubit.loadOptions('ad-1');
      await cubit.refreshQuote(_trip(fulfilment: 'delivery'));

      await cubit.confirmBooking(_trip(fulfilment: 'delivery'));

      expect(marketplace.placed.single.address, 'Villa 22, Koramangala');
      expect(cubit.state.booking!.deliveryAddress, 'Villa 22, Koramangala');
      expect(cubit.state.booking!.branchName, isNull);
    });

    test('refuses to book a trip that was never priced', () async {
      await cubit.loadOptions('ad-1');

      final ok = await cubit.confirmBooking(_trip());

      expect(ok, isFalse);
      expect(marketplace.placed, isEmpty);
    });

    test('surfaces a rejected booking and stops submitting', () async {
      await cubit.loadOptions('ad-1');
      await cubit.refreshQuote(_trip());
      marketplace.placeError = Exception('offline');

      final ok = await cubit.confirmBooking(_trip());

      expect(ok, isFalse);
      expect(cubit.state.bookingError, isNotNull);
      expect(cubit.state.isSubmitting, isFalse);
    });
  });
}
