import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';
import '../../../data/repositories/auth_repository.dart';

part 'splash_state.dart';

/// Decides where the app should land after the splash animation —
/// onboarding, login, or straight into the authenticated app.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._preferences, this._authRepository)
      : super(const SplashState());

  final AppPreferences _preferences;
  final AuthRepository _authRepository;

  /// Minimum time the splash choreography stays on screen.
  static const _minSplashDuration = Duration(milliseconds: 2800);

  Future<void> resolveDestination() async {
    final results = await Future.wait([
      Future<void>.delayed(_minSplashDuration),
      _resolve(),
    ]);
    emit(SplashState(destination: results[1] as SplashDestination));
  }

  Future<SplashDestination> _resolve() async {
    if (!_preferences.hasCompletedOnboarding) {
      return SplashDestination.onboarding;
    }
    if (_preferences.isGuest) {
      return SplashDestination.home;
    }
    try {
      final user = await _authRepository.restoreSession();
      return user != null ? SplashDestination.home : SplashDestination.login;
    } catch (_) {
      // Backend unreachable: trust the stored session rather than logging
      // the user out while offline.
      return _preferences.isAuthenticated
          ? SplashDestination.home
          : SplashDestination.login;
    }
  }
}
