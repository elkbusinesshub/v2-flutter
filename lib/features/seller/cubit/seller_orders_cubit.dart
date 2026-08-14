import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'seller_orders_state.dart';

/// Backs the seller panel's Orders tab and the dashboard's "needs attention"
/// rows.
///
/// Before this, `sellerOrders` was a `const []` fixture sitting under tabs that
/// read "New 3 / In progress 2 / Completed 4".
class SellerOrdersCubit extends Cubit<SellerOrdersState> {
  SellerOrdersCubit(this._repository) : super(const SellerOrdersState());

  final MarketplaceRepository _repository;

  /// Loads every status at once so the tab counts and the rows can never
  /// disagree — the same reason My Listings does it this way.
  Future<void> load() async {
    emit(state.copyWith(status: SellerOrdersStatus.loading));
    try {
      final orders = await _repository.sellerOrders();
      emit(state.copyWith(status: SellerOrdersStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(
        status: SellerOrdersStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void selectTab(AdOrderStatus tab) => emit(state.copyWith(tab: tab));

  /// Accepts, completes or declines an order.
  ///
  /// Not optimistic, unlike pausing a listing: the backend refuses illegal
  /// transitions with a 409, and showing "Completed" for a moment before
  /// snapping back would be worse than waiting for the answer.
  Future<void> setStatus(String orderId, AdOrderStatus next) async {
    emit(state.copyWith(busyId: orderId));
    try {
      final updated = await _repository.setOrderStatus(orderId, next);
      emit(state.copyWith(
        orders: [
          for (final o in state.orders) if (o.id == orderId) updated else o,
        ],
      ).clearBusy());
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)).clearBusy());
    }
  }
}
