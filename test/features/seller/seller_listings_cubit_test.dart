import 'package:elk/data/models/ad_models.dart';
import 'package:elk/features/seller/cubit/seller_listings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(String id, String title, AdStatus status) => AdModel.fromJson({
      'id': id,
      'title': title,
      'categorySlug': 'cleaning',
      'price': 180,
      'status': switch (status) {
        AdStatus.draft => 'DRAFT',
        AdStatus.paused => 'PAUSED',
        AdStatus.active => 'ACTIVE',
      },
    });

class _FakeMarketplaceRepository extends FakeMarketplaceRepositoryBase {
  List<AdModel> ads = [
    _ad('ad-1', 'Deep Clean', AdStatus.active),
    _ad('ad-2', 'Sofa Shampoo', AdStatus.active),
    _ad('ad-3', 'Curtain Clean', AdStatus.draft),
    _ad('ad-4', 'Old Listing', AdStatus.paused),
  ];
  Object? error;

  Map<String, dynamic>? lastCreate;
  final List<(String, AdStatus?)> updates = [];
  final List<String> deletes = [];

  @override
  Future<List<AdModel>> myAds({AdStatus? status}) async {
    if (error != null) throw error!;
    return status == null ? ads : ads.where((a) => a.status == status).toList();
  }

  @override
  Future<AdModel> createAd({
    required String title,
    required String categorySlug,
    required double price,
    String? description,
    String? priceUnit,
    String? locality,
    String? city,
    String? icon,
    AdStatus status = AdStatus.active,
    List<String> imageKeys = const [],
    Map<String, dynamic> attributes = const {},
  }) async {
    lastCreate = {
      'title': title,
      'categorySlug': categorySlug,
      'price': price,
      'priceUnit': priceUnit,
      'icon': icon,
      'status': status,
      'imageKeys': imageKeys,
      'attributes': attributes,
    };
    if (error != null) throw error!;
    return _ad('ad-new', title, status);
  }

  @override
  Future<AdModel> updateAd(
    String id, {
    String? title,
    String? categorySlug,
    double? price,
    String? description,
    String? priceUnit,
    String? locality,
    String? city,
    String? icon,
    AdStatus? status,
    List<String>? imageKeys,
    Map<String, dynamic>? attributes,
  }) async {
    updates.add((id, status));
    if (error != null) throw error!;
    return _ad(id, 'Updated', status ?? AdStatus.active);
  }

  @override
  Future<void> deleteAd(String id) async {
    deletes.add(id);
    if (error != null) throw error!;
  }
}

void main() {
  late _FakeMarketplaceRepository repository;
  late SellerListingsCubit cubit;

  setUp(() {
    repository = _FakeMarketplaceRepository();
    cubit = SellerListingsCubit(repository);
  });

  group('load', () {
    test('fetches every status in one call', () async {
      // The tabs filter client-side, so switching them costs no round trip and
      // the counts always match the rows.
      await cubit.load();

      expect(cubit.state.status, SellerListingsStatus.success);
      expect(cubit.state.ads, hasLength(4));
    });

    test('counts come from the loaded list, not from constants', () async {
      // The fixture panel showed "All 5 / Active 3" above an empty list.
      await cubit.load();

      expect(cubit.state.countOf(null), 4);
      expect(cubit.state.countOf(AdStatus.active), 2);
      expect(cubit.state.countOf(AdStatus.draft), 1);
      expect(cubit.state.countOf(AdStatus.paused), 1);
    });

    test('surfaces a failure', () async {
      repository.error = Exception('offline');

      await cubit.load();

      expect(cubit.state.status, SellerListingsStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('tabs', () {
    test('filters to the selected status and back to all', () async {
      await cubit.load();

      cubit.selectTab(AdStatus.draft);
      expect(cubit.state.visibleAds.map((a) => a.id), ['ad-3']);

      cubit.selectTab(null);
      expect(cubit.state.visibleAds, hasLength(4));
    });
  });

  group('create', () {
    test('publishes and puts the new listing at the top', () async {
      await cubit.load();

      final ok = await cubit.create(
        title: 'Sofa Shampoo Service',
        categorySlug: 'cleaning',
        price: 899,
        priceUnit: '/ visit',
        imageKeys: ['ads/a.jpg'],
      );

      expect(ok, isTrue);
      expect(repository.lastCreate, containsPair('status', AdStatus.active));
      expect(repository.lastCreate, containsPair('imageKeys', ['ads/a.jpg']));
      expect(cubit.state.ads.first.id, 'ad-new');
    });

    test('sends the category emoji so a photoless listing has an icon', () async {
      // Left unset, the ad takes the MySQL column default, which is stored as
      // a literal `?` — the emoji does not survive Prisma's DDL path.
      await cubit.create(
        title: 'Sofa Shampoo',
        categorySlug: 'cleaning',
        price: 899,
        icon: '🧹',
      );

      expect(repository.lastCreate, containsPair('icon', '🧹'));
    });

    test('sends the category-specific details the seller filled in', () async {
      await cubit.create(
        title: 'Swift Dzire',
        categorySlug: 'car_rental',
        price: 2400,
        attributes: const {'seats': 5, 'transmission': 'AUTOMATIC'},
      );

      expect(
        repository.lastCreate,
        containsPair('attributes', {'seats': 5, 'transmission': 'AUTOMATIC'}),
      );
    });

    test('saves a draft as DRAFT', () async {
      await cubit.create(
        title: 'Draft',
        categorySlug: 'cleaning',
        price: 10,
        status: AdStatus.draft,
      );

      expect(repository.lastCreate, containsPair('status', AdStatus.draft));
    });

    test('returns false on failure so the sheet can stay open', () async {
      // Closing it would lose everything the seller typed.
      repository.error = Exception('offline');

      final ok = await cubit.create(title: 'X', categorySlug: 'cleaning', price: 1);

      expect(ok, isFalse);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('pause and delete', () {
    test('pausing moves the ad between tabs immediately', () async {
      await cubit.load();

      await cubit.setPaused('ad-1', true);

      expect(repository.updates, [('ad-1', AdStatus.paused)]);
      expect(cubit.state.countOf(AdStatus.active), 1);
      expect(cubit.state.countOf(AdStatus.paused), 2);
    });

    test('resuming sends ACTIVE', () async {
      await cubit.load();

      await cubit.setPaused('ad-4', false);

      expect(repository.updates, [('ad-4', AdStatus.active)]);
    });

    test('a failed pause puts the ad back where it was', () async {
      await cubit.load();
      repository.error = Exception('offline');

      await cubit.setPaused('ad-1', true);

      expect(cubit.state.countOf(AdStatus.active), 2);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('deleting removes the row', () async {
      await cubit.load();

      await cubit.delete('ad-2');

      expect(repository.deletes, ['ad-2']);
      expect(cubit.state.ads.map((a) => a.id), isNot(contains('ad-2')));
    });

    test('a failed delete restores the row and says why', () async {
      await cubit.load();
      repository.error = Exception('offline');

      await cubit.delete('ad-2');

      expect(cubit.state.ads, hasLength(4));
      expect(cubit.state.errorMessage, isNotNull);
    });
  });
}
