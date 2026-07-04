import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';

part 'splash_state.dart';

/// Decides where the app should land after the splash animation —
/// onboarding, login, or straight into the authenticated app.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._preferences) : super(const SplashState());

  final AppPreferences _preferences;

  Future<void> resolveDestination() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!_preferences.hasCompletedOnboarding) {
      emit(const SplashState(destination: SplashDestination.onboarding));
    } else if (!_preferences.isAuthenticated) {
      emit(const SplashState(destination: SplashDestination.login));
    } else {
      emit(const SplashState(destination: SplashDestination.home));
    }
  }
}
