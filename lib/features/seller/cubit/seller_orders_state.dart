part of 'seller_orders_cubit.dart';

enum SellerOrdersStatus { initial, loading, success, error }

class SellerOrdersState extends Equatable {
  const SellerOrdersState({
    this.status = SellerOrdersStatus.initial,
    this.orders = const [],
    this.tab = AdOrderStatus.newOrder,
    this.busyId,
    this.errorMessage,
  });

  final SellerOrdersStatus status;
  final List<AdOrderModel> orders;

  /// Orders always open on "New" — that is the tab with work waiting.
  final AdOrderStatus tab;

  /// The order whose accept/complete/decline call is in flight.
  final String? busyId;

  final String? errorMessage;

  List<AdOrderModel> get visibleOrders =>
      orders.where((o) => o.status == tab).toList();

  int countOf(AdOrderStatus tab) => orders.where((o) => o.status == tab).length;

  /// What the dashboard's "needs attention" card counts: anything the seller
  /// still has to act on.
  int get needsAttention =>
      countOf(AdOrderStatus.newOrder) + countOf(AdOrderStatus.inProgress);

  List<AdOrderModel> get attentionOrders => orders
      .where((o) =>
          o.status == AdOrderStatus.newOrder ||
          o.status == AdOrderStatus.inProgress)
      .take(3)
      .toList();

  SellerOrdersState copyWith({
    SellerOrdersStatus? status,
    List<AdOrderModel>? orders,
    AdOrderStatus? tab,
    String? busyId,
    String? errorMessage,
  }) =>
      SellerOrdersState(
        status: status ?? this.status,
        orders: orders ?? this.orders,
        tab: tab ?? this.tab,
        busyId: busyId ?? this.busyId,
        errorMessage: errorMessage,
      );

  SellerOrdersState clearBusy() => SellerOrdersState(
        status: status,
        orders: orders,
        tab: tab,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, orders, tab, busyId, errorMessage];
}
