import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/models/stay_models.dart';
import 'package:elk/features/elkstay/explore/cubit/elkstay_explore_cubit.dart';
import 'package:elk/features/elkstay/favorites/cubit/stay_favorites_cubit.dart';
import 'package:elk/features/elkstay/home/cubit/elkstay_home_cubit.dart';
import 'package:elk/features/elkstay/stay_detail/cubit/stay_detail_cubit.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(
  String id,
  String title, {
  String? stayType,
  double price = 9000,
  String? roomType,
  int? deposit,
  bool furnished = false,
  bool isWishlisted = false,
  int wishlistCount = 0,
}) =>
    AdModel.fromJson({
      'id': id,
      'title': title,
      'description': 'Quiet, near the metro.',
      'sellerName': 'Maple Nest',
      'categorySlug': 'elkstay',
      'price': price,
      'location': 'Koramangala, Bengaluru',
      'isWishlisted': isWishlisted,
      'wishlistCount': wishlistCount,
      'attributes': {
        'stayType': ?stayType,
        'roomType': ?roomType,
        'depositAmount': ?deposit,
        'furnished': furnished,
      },
    });

class _FakeMarketplace extends FakeMarketplaceRepositoryBase {
  List<AdModel> ads = [
    _ad('ad-1', 'Maple Nest', stayType: 'PG', roomType: 'Single room', deposit: 15000),
    _ad('ad-2', 'Cedar House', stayType: 'MENS_HOSTEL', price: 14000, roomType: 'Double sharing'),
    _ad('ad-3', 'Willow Court', stayType: 'HOMESTAY', price: 20000, roomType: 'Studio'),
  ];
  String? requestedCategory;
  String? requestedQuery;
  Object? error;

  final List<(String, bool)> wishlistCalls = [];
  final List<
      ({
        String adId,
        int quantity,
        DateTime? scheduledAt,
        int? durationMonths,
        double? depositAmount,
        String? note,
      })> placed = [];
  Object? placeError;

  @override
  Future<List<AdModel>> listAds({String? query, String? category, int? limit}) async {
    requestedCategory = category;
    requestedQuery = query;
    if (error != null) throw error!;
    return ads;
  }

  @override
  Future<AdModel> getAd(String id) async {
    if (error != null) throw error!;
    return ads.firstWhere((a) => a.id == id);
  }

  @override
  Future<({bool isWishlisted, int wishlistCount})> setWishlisted(
    String adId, {
    required bool wishlisted,
  }) async {
    wishlistCalls.add((adId, wishlisted));
    if (error != null) throw error!;
    return (isWishlisted: wishlisted, wishlistCount: wishlisted ? 1 : 0);
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
      durationMonths: durationMonths,
      depositAmount: depositAmount,
      note: note,
    ));
    if (placeError != null) throw placeError!;
    return AdOrderModel.fromJson({
      'id': 'o-1',
      'code': 'ELK-A-7GK2P',
      'adId': adId,
      'status': 'NEW',
      'amount': 9000,
      'serviceName': 'Maple Nest',
    });
  }
}

void main() {
  late _FakeMarketplace marketplace;
  late AppPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Rafseena',
      'user_phone': '+919562461531',
    });
    preferences = AppPreferences(await SharedPreferences.getInstance());
    marketplace = _FakeMarketplace();
  });

  group('home', () {
    late ElkStayHomeCubit cubit;
    setUp(() => cubit = ElkStayHomeCubit(marketplace, preferences));

    test('shows what sellers listed under elkstay', () async {
      await cubit.loadHomeData();

      expect(marketplace.requestedCategory, 'elkstay');
      expect(cubit.state.status, ElkStayHomeStatus.success);
      expect(cubit.state.feed!.topRated, hasLength(3));
    });

    test('counts the property-type tiles from the listings', () async {
      await cubit.loadHomeData();

      final categories = cubit.state.feed!.categories;
      expect(categories.map((c) => c.type), [
        StayCategoryType.pgStay,
        StayCategoryType.mensHostel,
        StayCategoryType.homestay,
      ]);
      expect(categories.every((c) => c.count == 1), isTrue);
    });

    test('leaves out a type nobody is offering', () async {
      await cubit.loadHomeData();

      expect(
        cubit.state.feed!.categories.map((c) => c.type),
        isNot(contains(StayCategoryType.womensHostel)),
      );
    });

    test('files an unlabelled listing as a PG rather than hiding it', () async {
      marketplace.ads = [_ad('ad-9', 'Unknown Place')];

      await cubit.loadHomeData();

      expect(cubit.state.feed!.topRated.single.categoryType, StayCategoryType.pgStay);
    });

    test('guest mode never reaches the network', () async {
      SharedPreferences.setMockInitialValues({'is_guest': true});
      cubit = ElkStayHomeCubit(marketplace, AppPreferences(await SharedPreferences.getInstance()));

      await cubit.loadHomeData();

      expect(cubit.state.status, ElkStayHomeStatus.guest);
      expect(marketplace.requestedCategory, isNull);
    });

    test('surfaces a failure', () async {
      marketplace.error = Exception('offline');

      await cubit.loadHomeData();

      expect(cubit.state.status, ElkStayHomeStatus.error);
    });
  });

  group('explore', () {
    late ElkStayExploreCubit cubit;
    setUp(() => cubit = ElkStayExploreCubit(marketplace, preferences));

    test('lists the category', () async {
      await cubit.loadStays();

      expect(marketplace.requestedCategory, 'elkstay');
      expect(cubit.state.stays, hasLength(3));
    });

    test('narrows by property type without another round trip', () async {
      await cubit.loadStays();
      marketplace.requestedCategory = null;

      await cubit.filterByCategory(StayCategoryType.homestay);

      expect(cubit.state.stays.map((s) => s.name), ['Willow Court']);
    });

    test('the price chip keeps only what is under the cap', () async {
      await cubit.loadStays();

      await cubit.togglePriceFilter();

      // ₹20,000 is over the ₹12,000 cap.
      expect(cubit.state.stays.map((s) => s.name), ['Maple Nest']);
    });

    test('the room-type chip matches on what the seller typed', () async {
      await cubit.loadStays();

      await cubit.setRoomType('single');

      expect(cubit.state.stays.map((s) => s.name), ['Maple Nest']);
    });

    test('search asks the backend, since it matches the seller name too', () async {
      await cubit.loadStays();

      await cubit.search('cedar');

      expect(marketplace.requestedQuery, 'cedar');
    });

    test('does not send a one-character search the backend would refuse', () async {
      await cubit.search('c');

      expect(marketplace.requestedQuery, isNull);
    });
  });

  group('detail', () {
    late StayDetailCubit cubit;
    setUp(() => cubit = StayDetailCubit(marketplace, preferences));

    test('builds one room option from the listing itself', () async {
      // A listing is one room at one rent, and the booking is priced from it.
      await cubit.loadDetail('ad-1');

      expect(cubit.state.status, StayDetailStatus.success);
      expect(cubit.state.roomOptions.single.kind, 'Single room');
      expect(cubit.state.roomOptions.single.pricePerMonth, 9000);
      expect(cubit.state.selectedRoomOptionId, 'ad-1');
    });

    test('shows the amenity a seller actually set', () async {
      marketplace.ads = [_ad('ad-1', 'Maple Nest', stayType: 'PG', furnished: true)];

      await cubit.loadDetail('ad-1');

      expect(cubit.state.stay!.amenities.single.label, 'Furnished');
    });

    test('saving writes through the wishlist', () async {
      await cubit.loadDetail('ad-1');

      await cubit.toggleSaved();

      expect(marketplace.wishlistCalls, [('ad-1', true)]);
      expect(cubit.state.isSaved, isTrue);
    });

    test('a failed save rolls the heart back', () async {
      await cubit.loadDetail('ad-1');
      marketplace.error = Exception('offline');

      await cubit.toggleSaved();

      expect(cubit.state.isSaved, isFalse);
    });

    test('a reservation carries the term and the deposit', () async {
      await cubit.loadDetail('ad-1');

      final booking = await cubit.requestToBook(
        moveInDate: '2026-09-01',
        durationMonths: 6,
        paymentMethod: 'card',
      );

      final order = marketplace.placed.single;
      // Months, not rooms — a stay is priced per month.
      expect(order.quantity, 6);
      expect(order.durationMonths, 6);
      expect(order.depositAmount, 15000);
      expect(booking!.status, StayBookingStatus.confirmed);
      expect(booking.secondaryValue, '6 months');
    });

    test('a visit carries no term and no deposit', () async {
      // The same order shape; what distinguishes it is what it leaves out.
      await cubit.loadDetail('ad-1');

      final visit = await cubit.scheduleVisit('2026-09-01T11:00:00.000');

      final order = marketplace.placed.single;
      expect(order.durationMonths, isNull);
      expect(order.depositAmount, isNull);
      expect(order.quantity, 1);
      expect(order.note, contains('visit'));
      expect(visit!.status, StayBookingStatus.visitBooked);
    });

    test('surfaces a refused booking', () async {
      await cubit.loadDetail('ad-1');
      marketplace.placeError = Exception('offline');

      final booking = await cubit.requestToBook(
        moveInDate: '2026-09-01',
        durationMonths: 6,
        paymentMethod: 'card',
      );

      expect(booking, isNull);
      expect(cubit.state.actionError, isNotNull);
      expect(cubit.state.isSubmitting, isFalse);
    });
  });

  group('favorites', () {
    late StayFavoritesCubit cubit;
    setUp(() => cubit = StayFavoritesCubit(marketplace, preferences));

    test('shows only the listings the caller has saved', () async {
      // There is no "list my saved ads" endpoint; every listing carries
      // isWishlisted for the caller, so that flag is the filter.
      marketplace.ads = [
        _ad('ad-1', 'Maple Nest', isWishlisted: true),
        _ad('ad-2', 'Cedar House'),
        _ad('ad-3', 'Willow Court', isWishlisted: true),
      ];

      await cubit.load();

      expect(cubit.state.stays.map((s) => s.name), ['Maple Nest', 'Willow Court']);
    });

    test('removing drops the row and unsaves it', () async {
      marketplace.ads = [_ad('ad-1', 'Maple Nest', isWishlisted: true)];
      await cubit.load();

      await cubit.remove('ad-1');

      expect(marketplace.wishlistCalls, [('ad-1', false)]);
      expect(cubit.state.stays, isEmpty);
    });

    test('a failed unsave puts the row back', () async {
      marketplace.ads = [_ad('ad-1', 'Maple Nest', isWishlisted: true)];
      await cubit.load();
      marketplace.error = Exception('offline');

      await cubit.remove('ad-1');

      expect(cubit.state.stays, hasLength(1));
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('guest mode never reaches the network', () async {
      SharedPreferences.setMockInitialValues({'is_guest': true});
      cubit = StayFavoritesCubit(marketplace, AppPreferences(await SharedPreferences.getInstance()));

      await cubit.load();

      expect(cubit.state.status, StayFavoritesStatus.guest);
      expect(marketplace.requestedCategory, isNull);
    });
  });
}
