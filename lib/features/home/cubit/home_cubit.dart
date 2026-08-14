import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/home_models.dart';
import '../../../data/repositories/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._preferences) : super(const HomeState());

  final HomeRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // Guests have no backend session — serve the static local feed.
      final feed = _preferences.isGuest
          ? _repository.guestFeed()
          : await _repository.getHomeFeed();
      emit(state.copyWith(status: HomeStatus.loaded, feed: feed));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
