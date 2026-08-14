import 'package:elk/data/models/ad_models.dart';
import 'package:elk/features/seller/cubit/seller_orders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_marketplace_repository.dart';

AdOrderModel _order(String id, AdOrderStatus status) => AdOrderModel.fromJson({
      'id': id,
      'code': 'ELK-A-$id',
      'adId': 'ad-1',
      'status': status.wireValue,
      'amount': 899,
      'serviceName': 'Sofa Shampoo',
      'customerName': 'Aarav Menon',
      'customerPhone': '+919000000001',
      'addressText': '12, 5th Block',
      'whenLabel': 'As soon as possible',
    });

class _FakeMarketplaceRepository extends FakeMarketplaceRepositoryBase {
  List<AdOrderModel> orders = [
    _order('o-1', AdOrderStatus.newOrder),
    _order('o-2', AdOrderStatus.newOrder),
    _order('o-3', AdOrderStatus.inProgress),
    _order('o-4', AdOrderStatus.completed),
    _order('o-5', AdOrderStatus.cancelled),
  ];
  Object? error;
  final List<(String, AdOrderStatus)> transitions = [];

  @override
  Future<List<AdOrderModel>> sellerOrders({AdOrderStatus? status}) async {
    if (error != null) throw error!;
    return status == null ? orders : orders.where((o) => o.status == status).toList();
  }

  @override
  Future<AdOrderModel> setOrderStatus(String orderId, AdOrderStatus status) async {
    transitions.add((orderId, status));
    if (error != null) throw error!;
    return _order(orderId, status);
  }
}

void main() {
  late _FakeMarketplaceRepository repository;
  late SellerOrdersCubit cubit;

  setUp(() {
    repository = _FakeMarketplaceRepository();
    cubit = SellerOrdersCubit(repository);
  });

  group('load', () {
    test('fetches every status in one call', () async {
      await cubit.load();

      expect(cubit.state.status, SellerOrdersStatus.success);
      expect(cubit.state.orders, hasLength(5));
    });

    test('counts come from the loaded orders, not from constants', () async {
      // The fixture panel showed "New 3 / In progress 2 / Completed 4" above
      // an empty list.
      await cubit.load();

      expect(cubit.state.countOf(AdOrderStatus.newOrder), 2);
      expect(cubit.state.countOf(AdOrderStatus.inProgress), 1);
      expect(cubit.state.countOf(AdOrderStatus.completed), 1);
      expect(cubit.state.countOf(AdOrderStatus.cancelled), 1);
    });

    test('opens on New, the tab with work waiting', () async {
      await cubit.load();

      expect(cubit.state.tab, AdOrderStatus.newOrder);
      expect(cubit.state.visibleOrders.map((o) => o.id), ['o-1', 'o-2']);
    });

    test('surfaces a failure', () async {
      repository.error = Exception('offline');

      await cubit.load();

      expect(cubit.state.status, SellerOrdersStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('dashboard summary', () {
    test('needs-attention counts only what the seller must still act on',
        () async {
      // Completed and cancelled orders need nothing.
      await cubit.load();

      expect(cubit.state.needsAttention, 3);
    });

    test('shows at most three attention rows', () async {
      repository.orders = [
        for (var i = 0; i < 6; i++) _order('o-$i', AdOrderStatus.newOrder),
      ];
      await cubit.load();

      expect(cubit.state.attentionOrders, hasLength(3));
    });
  });

  group('transitions', () {
    test('accepting moves the order out of New', () async {
      await cubit.load();

      await cubit.setStatus('o-1', AdOrderStatus.inProgress);

      expect(repository.transitions, [('o-1', AdOrderStatus.inProgress)]);
      expect(cubit.state.countOf(AdOrderStatus.newOrder), 1);
      expect(cubit.state.countOf(AdOrderStatus.inProgress), 2);
    });

    test('completing moves it again', () async {
      await cubit.load();

      await cubit.setStatus('o-3', AdOrderStatus.completed);

      expect(cubit.state.countOf(AdOrderStatus.completed), 2);
    });

    test('declining cancels it', () async {
      await cubit.load();

      await cubit.setStatus('o-1', AdOrderStatus.cancelled);

      expect(repository.transitions, [('o-1', AdOrderStatus.cancelled)]);
      expect(cubit.state.countOf(AdOrderStatus.cancelled), 2);
    });

    test('a rejected transition leaves the order where it was', () async {
      // The backend refuses illegal moves with a 409; the row must not have
      // already moved on screen.
      await cubit.load();
      repository.error = Exception('conflict');

      await cubit.setStatus('o-1', AdOrderStatus.completed);

      expect(cubit.state.countOf(AdOrderStatus.newOrder), 2);
      expect(cubit.state.countOf(AdOrderStatus.completed), 1);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('clears the busy marker whether it succeeds or fails', () async {
      await cubit.load();

      await cubit.setStatus('o-1', AdOrderStatus.inProgress);
      expect(cubit.state.busyId, isNull);

      repository.error = Exception('offline');
      await cubit.setStatus('o-2', AdOrderStatus.inProgress);
      expect(cubit.state.busyId, isNull);
    });
  });
}
