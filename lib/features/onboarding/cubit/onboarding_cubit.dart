import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._preferences) : super(const OnboardingState());

  final AppPreferences _preferences;

  static const totalPages = 3;

  void pageChanged(int index) => emit(state.copyWith(pageIndex: index));

  Future<void> complete() async {
    await _preferences.setOnboardingComplete();
    emit(state.copyWith(completed: true));
  }
}
