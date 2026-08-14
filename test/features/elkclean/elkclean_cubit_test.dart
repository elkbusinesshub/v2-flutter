import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/models/location_models.dart';
import 'package:elk/data/repositories/locations_repository.dart';
import 'package:elk/features/elkclean/cubit/elkclean_cubit.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(
  String id,
  String title, {
  String? subCategory,
  double price = 79,
  int wishlistCount = 0,
  String location = 'Koramangala, Bengaluru',
  Map<String, dynamic>? attributes,
}) =>
    AdModel.fromJson({
      'id': id,
      'title': title,
      'description': 'Dusting, mopping & surface wipe-down.',
      'sellerName': 'Bright Spark Services',
      'categorySlug': 'cleaning',
      'price': price,
      'location': location,
      'wishlistCount': wishlistCount,
      'attributes': {'subCategory': ?subCategory, ...?attributes},
    });

class _FakeMarketplace extends FakeMarketplaceRepositoryBase {
  List<AdModel> ads = [
    _ad('ad-1', 'Standard Home Cleaning', subCategory: 'cln'),
    _ad('ad-2', 'Deep Cleaning', subCategory: 'deep', price: 199),
    _ad('ad-3', 'Move-out Clean', subCategory: 'cln', price: 149),
  ];
  String? requestedCategory;
  Object? error;

  /// Every order placed, in the order they were placed.
  final List<
      ({
        String adId,
        int quantity,
        DateTime? scheduledAt,
        String address,
        double? lat,
        double? lng,
      })> placed = [];
  Object? placeError;

  @override
  Future<List<AdModel>> listAds({String? query, String? category, int? limit}) async {
    requestedCategory = category;
    if (error != null) throw error!;
    return ads;
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
    placed.add((
      adId: adId,
      quantity: quantity,
      scheduledAt: scheduledAt,
      address: addressText,
      lat: lat,
      lng: lng,
    ));
    if (placeError != null) throw placeError!;
    return AdOrderModel.fromJson({
      'id': 'o-$adId',
      'code': 'ELK-A-${adId.toUpperCase()}',
      'adId': adId,
      'status': 'NEW',
      'amount': 79,
      'serviceName': 'Standard Home Cleaning',
    });
  }
}

class _FakeLocations implements LocationsRepository {
  List<AddressModel> addresses = [
    AddressModel(
      id: 'addr-1',
      label: 'Home',
      formattedAddress: 'Tower 3, Koramangala',
      lat: 12.9,
      lng: 77.6,
    ),
    AddressModel(
      id: 'addr-2',
      label: 'Villa',
      formattedAddress: 'Villa 22',
      lat: 12.9,
      lng: 77.6,
      isDefault: true,
    ),
  ];

  @override
  Future<List<AddressModel>> getAddresses() async => addresses;

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeMarketplace marketplace;
  late _FakeLocations locations;
  late AppPreferences preferences;
  late ElkCleanCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Rafseena',
      'user_phone': '+919562461531',
    });
    preferences = AppPreferences(await SharedPreferences.getInstance());
    marketplace = _FakeMarketplace();
    locations = _FakeLocations();
    cubit = ElkCleanCubit(marketplace, locations, preferences);
  });

  group('home feed', () {
    test('shows what sellers listed under cleaning, not a seeded catalogue', () async {
      await cubit.loadHome();

      expect(marketplace.requestedCategory, 'cleaning');
      expect(cubit.state.feedStatus, CleanViewStatus.loaded);
      expect(cubit.state.feed!.userName, 'Rafseena');
    });

    test('builds the tile grid from the listings themselves', () async {
      await cubit.loadHome();

      final categories = cubit.state.feed!.categories;
      // Two listings under Home Cleaning, one under Deep — most-stocked first.
      expect(categories.map((c) => c.slug), ['cln', 'deep']);
      expect(categories.first.serviceCount, 2);
      expect(categories.first.label, 'Home Cleaning');
    });

    test('shows no tile for a category nobody is offering', () async {
      // An empty tile is a dead end; the grid reflects real supply.
      await cubit.loadHome();

      expect(cubit.state.feed!.categories.map((c) => c.slug), isNot(contains('tnk')));
    });

    test('files a listing with no sub-category under Home Cleaning', () async {
      // It must still be reachable rather than vanishing from the screen.
      marketplace.ads = [_ad('ad-9', 'Odd job')];

      await cubit.loadHome();

      expect(cubit.state.feed!.categories.single.slug, 'cln');
    });

    test('surfaces a failure', () async {
      marketplace.error = Exception('offline');

      await cubit.loadHome();

      expect(cubit.state.feedStatus, CleanViewStatus.error);
      expect(cubit.state.feedError, isNotNull);
    });

    test('guest mode never reaches the network', () async {
      SharedPreferences.setMockInitialValues({'is_guest': true});
      cubit = ElkCleanCubit(
        marketplace,
        locations,
        AppPreferences(await SharedPreferences.getInstance()),
      );

      await cubit.loadHome();

      expect(cubit.state.feedStatus, CleanViewStatus.guest);
      expect(marketplace.requestedCategory, isNull);
    });
  });

  group('opening a tile', () {
    test('filters the listings already loaded rather than refetching', () async {
      await cubit.loadHome();
      marketplace.requestedCategory = null;

      await cubit.openCategory(cubit.state.feed!.categories.first);

      expect(marketplace.requestedCategory, isNull);
      expect(cubit.state.services.map((s) => s.id), ['ad-1', 'ad-3']);
    });

    test('maps a listing onto the service card the screen renders', () async {
      marketplace.ads = [
        _ad('ad-1', 'Sofa Shampoo',
            subCategory: 'cln',
            price: 899,
            wishlistCount: 6,
            attributes: {
              'durationLabel': '2–3 hrs',
              'includes': ['Sofa', 'Carpet'],
            }),
      ];
      await cubit.loadHome();

      await cubit.openCategory(cubit.state.feed!.categories.first);

      final service = cubit.state.services.single;
      expect(service.name, 'Sofa Shampoo');
      expect(service.price, 899);
      expect(service.duration, '2–3 hrs');
      expect(service.checklist, ['Sofa', 'Carpet']);
      // Engagement stands in for the curated "Popular" flag.
      expect(service.tag, 'Popular');
    });
  });

  group('booking options', () {
    test('offers dates and slots without a backend that serves them', () async {
      await cubit.loadBookingOptions();

      expect(cubit.state.optionsStatus, CleanViewStatus.loaded);
      expect(cubit.state.options!.dates, isNotEmpty);
      expect(cubit.state.options!.timeSlots, isNotEmpty);
    });

    test('never offers a window that has already passed today', () async {
      await cubit.loadBookingOptions();

      final today = cubit.state.options!.dates.first;
      final now = DateTime.now();
      final isToday = today.day == now.day;
      if (isToday) {
        for (final slot in today.slots) {
          expect(int.parse(slot.split(':')[0]), greaterThan(now.hour));
        }
      }
    });

    test('preselects the default address', () async {
      await cubit.loadBookingOptions();

      expect(cubit.state.addressId, 'addr-2');
    });
  });

  group('checkout', () {
    Future<void> readyToBook() async {
      await cubit.loadHome();
      await cubit.openCategory(cubit.state.feed!.categories.first);
      await cubit.loadBookingOptions();
    }

    test('places one order per cart line, since sellers may differ', () async {
      // Two listings can belong to two people, and each has to reach whoever
      // will do the work — one combined order could not.
      await readyToBook();
      cubit.addService(cubit.state.services[0]);
      cubit.addService(cubit.state.services[1]);
      cubit.incrementLine(cubit.state.services[0].id);

      final ok = await cubit.confirmBooking();

      expect(ok, isTrue);
      expect(marketplace.placed.map((p) => p.adId), ['ad-1', 'ad-3']);
      expect(marketplace.placed.first.quantity, 2);
      expect(marketplace.placed.first.address, 'Villa 22');
    });

    test('sends the saved address’s pin so tracking can show a map', () async {
      // The picker resolved a coordinate when the address was saved; dropping
      // it here is what left every order without one to centre on.
      await readyToBook();
      cubit.addService(cubit.state.services.first);

      await cubit.confirmBooking();

      expect(marketplace.placed.single.lat, 12.9);
      expect(marketplace.placed.single.lng, 77.6);
    });

    test('sends the chosen date and window as one instant', () async {
      await readyToBook();
      cubit.addService(cubit.state.services.first);
      cubit.selectTimeSlot(cubit.state.availableTimeSlots.first);

      await cubit.confirmBooking();

      final slot = cubit.state.confirmation!.timeSlot;
      final at = marketplace.placed.single.scheduledAt!;
      expect(at.hour, int.parse(slot.split(':')[0]));
    });

    test('clears the cart and reports a reference on success', () async {
      await readyToBook();
      cubit.addService(cubit.state.services.first);

      await cubit.confirmBooking();

      expect(cubit.state.cart, isEmpty);
      expect(cubit.state.confirmation!.code, startsWith('ELK-A-'));
      expect(cubit.state.confirmation!.addressLabel, 'Villa');
    });

    test('keeps the cart when an order is refused', () async {
      await readyToBook();
      cubit.addService(cubit.state.services.first);
      marketplace.placeError = Exception('offline');

      final ok = await cubit.confirmBooking();

      expect(ok, isFalse);
      expect(cubit.state.cart, hasLength(1));
      expect(cubit.state.bookingError, isNotNull);
      expect(cubit.state.isBooking, isFalse);
    });

    test('refuses to book with an empty cart', () async {
      await readyToBook();

      final ok = await cubit.confirmBooking();

      expect(ok, isFalse);
      expect(marketplace.placed, isEmpty);
    });
  });
}
