import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/stay_models.dart';
import '../../../../data/repositories/elkstay_repository.dart';

part 'elkstay_home_state.dart';

class ElkStayHomeCubit extends Cubit<ElkStayHomeState> {
  ElkStayHomeCubit(this._repository) : super(const ElkStayHomeState());

  final ElkStayRepository _repository;

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: ElkStayHomeStatus.loading));
    try {
      final feed = await _repository.fetchHomeData();
      emit(state.copyWith(status: ElkStayHomeStatus.success, feed: feed));
    } catch (e) {
      emit(state.copyWith(
        status: ElkStayHomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
