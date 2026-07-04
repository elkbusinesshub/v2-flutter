import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/elkstay_repository.dart';

part 'elkstay_explore_state.dart';

class ElkStayExploreCubit extends Cubit<ElkStayExploreState> {
  ElkStayExploreCubit(this._repository) : super(const ElkStayExploreState());

  final ElkStayRepository _repository;

  Future<void> loadStays({StayCategoryType? filter}) async {
    emit(state.copyWith(
      status: ElkStayExploreStatus.loading,
      activeCategory: filter,
      clearCategory: filter == null,
    ));
    try {
      final stays = await _repository.fetchStays(filter: filter);
      emit(state.copyWith(status: ElkStayExploreStatus.success, stays: stays));
    } catch (e) {
      emit(state.copyWith(
        status: ElkStayExploreStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> filterByCategory(StayCategoryType type) => loadStays(filter: type);

  void toggleVerified() =>
      emit(state.copyWith(verifiedOnly: !state.verifiedOnly));
  void togglePriceFilter() =>
      emit(state.copyWith(priceFilter: !state.priceFilter));
  void toggleSingleRoom() =>
      emit(state.copyWith(singleRoomOnly: !state.singleRoomOnly));
  void toggleMeals() =>
      emit(state.copyWith(mealsIncluded: !state.mealsIncluded));
}
