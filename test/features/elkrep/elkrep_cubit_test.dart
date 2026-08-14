import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/models/location_models.dart';
import 'package:elk/data/repositories/locations_repository.dart';
import 'package:elk/features/elkrep/cubit/elkrep_cubit.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(
  String id,
  String title, {
  String? subCategory,
  double price = 499,
  int wishlistCount = 0,
  Map<String, dynamic>? attributes,
}) =>
    AdModel.fromJson({
      'id': id,
      'title': title,
      'description': 'Diagnose and fix.',
      'sellerName': 'CoolAir Services',
      'categorySlug': 'repairing',
      'price': price,
      'location': 'Indiranagar, Bengaluru',
      'wishlistCount': wishlistCount,
      'attributes': {'subCategory': ?subCategory, ...?attributes},
    });

class _FakeMarketplace extends FakeMarketplaceRepositoryBase {
  List<AdModel> ads = [
    _ad('ad-1', 'AC Gas Refill', subCategory: 'ac'),
    _ad('ad-2', 'AC Deep Clean', subCategory: 'ac', price: 899),
    _ad('ad-3', 'Tap Leak Fix', subCategory: 'plm', price: 349),
  ];
  String? requestedCategory;
  Object? error;

  final List<({String adId, int quantity, DateTime? scheduledAt, String address})> placed = [];
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
    ));
    if (placeError != null) throw placeError!;
    return AdOrderModel.fromJson({
      'id': 'o-$adId',
      'code': 'ELK-A-${adId.toUpperCase()}',
      'adId': adId,
      'status': 'NEW',
      'amount': 499,
      'serviceName': 'AC Gas Refill',
    });
  }
}

class _FakeLocations implements LocationsRepository {
  @override
  Future<List<AddressModel>> getAddresses() async => [
        AddressModel(
          id: 'addr-1',
          label: 'Home',
          formattedAddress: 'Tower 3',
          lat: 12.9,
          lng: 77.6,
        ),
        AddressModel(
          id: 'addr-2',
          label: 'Office',
          formattedAddress: 'Level 4, MG Road',
          lat: 12.9,
          lng: 77.6,
          isDefault: true,
        ),
      ];

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeMarketplace marketplace;
  late ElkRepCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Rafseena',
      'user_phone': '+919562461531',
    });
    marketplace = _FakeMarketplace();
    cubit = ElkRepCubit(
      marketplace,
      _FakeLocations(),
      AppPreferences(await SharedPreferences.getInstance()),
    );
  });

  group('home feed', () {
    test('shows what sellers listed under repairing', () async {
      await cubit.loadHome();

      expect(marketplace.requestedCategory, 'repairing');
      expect(cubit.state.feedStatus, RepairViewStatus.loaded);
    });

    test('builds the trade grid from the listings themselves', () async {
      await cubit.loadHome();

      final categories = cubit.state.feed!.categories;
      expect(categories.map((c) => c.slug), ['ac', 'plm']);
      expect(categories.first.label, 'AC & Cooling');
      expect(categories.first.serviceCount, 2);
    });

    test('files an unlabelled listing under Handyman', () async {
      marketplace.ads = [_ad('ad-9', 'Odd job')];

      await cubit.loadHome();

      expect(cubit.state.feed!.categories.single.slug, 'gen');
    });

    test('surfaces a failure', () async {
      marketplace.error = Exception('offline');

      await cubit.loadHome();

      expect(cubit.state.feedStatus, RepairViewStatus.error);
      expect(cubit.state.feedError, isNotNull);
    });

    test('guest mode never reaches the network', () async {
      SharedPreferences.setMockInitialValues({'is_guest': true});
      cubit = ElkRepCubit(
        marketplace,
        _FakeLocations(),
        AppPreferences(await SharedPreferences.getInstance()),
      );

      await cubit.loadHome();

      expect(cubit.state.feedStatus, RepairViewStatus.guest);
      expect(marketplace.requestedCategory, isNull);
    });
  });

  group('opening a trade', () {
    test('filters the listings already loaded rather than refetching', () async {
      await cubit.loadHome();
      marketplace.requestedCategory = null;

      await cubit.openCategory(cubit.state.feed!.categories.first);

      expect(marketplace.requestedCategory, isNull);
      expect(cubit.state.services.map((s) => s.id), ['ad-1', 'ad-2']);
    });

    test('shows the warranty a seller offers rather than boilerplate', () async {
      // Every seeded job carried the same "what's included" text; a warranty
      // is real, listing-specific information.
      marketplace.ads = [
        _ad('ad-1', 'AC Gas Refill', subCategory: 'ac', attributes: {
          'durationLabel': '45-60 mins',
          'warrantyLabel': '30 days on parts',
        }),
      ];
      await cubit.loadHome();

      await cubit.openCategory(cubit.state.feed!.categories.first);

      final service = cubit.state.services.single;
      expect(service.duration, '45-60 mins');
      expect(service.included, ['Warranty: 30 days on parts']);
    });
  });

  group('checkout', () {
    Future<void> readyToBook() async {
      await cubit.loadHome();
      await cubit.openCategory(cubit.state.feed!.categories.first);
      await cubit.loadBookingOptions();
    }

    test('preselects the default address', () async {
      await cubit.loadBookingOptions();

      expect(cubit.state.addressId, 'addr-2');
    });

    test('places one order per cart line, since tradespeople may differ', () async {
      await readyToBook();
      cubit.addService(cubit.state.services[0]);
      cubit.addService(cubit.state.services[1]);
      cubit.incrementLine(cubit.state.services[1].id);

      final ok = await cubit.confirmBooking();

      expect(ok, isTrue);
      expect(marketplace.placed.map((p) => p.adId), ['ad-1', 'ad-2']);
      expect(marketplace.placed.last.quantity, 2);
      expect(marketplace.placed.first.address, 'Level 4, MG Road');
    });

    test('clears the cart and reports a reference on success', () async {
      await readyToBook();
      cubit.addService(cubit.state.services.first);

      await cubit.confirmBooking();

      expect(cubit.state.cart, isEmpty);
      expect(cubit.state.confirmation!.code, startsWith('ELK-A-'));
      expect(cubit.state.confirmation!.addressLabel, 'Office');
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
