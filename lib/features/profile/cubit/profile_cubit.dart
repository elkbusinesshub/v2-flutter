import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../core/push/push_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._repository,
    this._authRepository,
    this._preferences, {
    PushService? push,
  })  : _push = push,
        super(const ProfileState());

  final ProfileRepository _repository;
  final AuthRepository _authRepository;
  final AppPreferences _preferences;
  final PushService? _push;

  Future<void> loadProfile() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ProfileStatus.guest));
      return;
    }
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _repository.getProfile();
      // Keep local flags in sync with the server-side profile.
      await _preferences.setUserName(user.name);
      await _preferences.setUserPhone(user.phone);
      await _preferences.setSelectedLanguage(user.language);
      emit(state.copyWith(status: ProfileStatus.loaded, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Saves the edited fields. Returns true on success; on failure the
  /// current profile stays on screen and [ProfileState.errorMessage] holds
  /// the reason.
  Future<bool> updateProfile({String? name, String? email}) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final user = await _repository.updateProfile(name: name, email: email);
      await _preferences.setUserName(user.name);
      emit(state.copyWith(isSaving: false, user: user));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: friendlyErrorMessage(e),
      ));
      return false;
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSigningOut: true));
    try {
      // Before logout: releasing the token needs a session the backend still
      // accepts, and the next user of this phone must not inherit the pushes.
      await _push?.unregister();
      await _authRepository.logout();
      await _preferences.setAuthenticated(false);
      await _preferences.setGuest(false);
    } finally {
      emit(state.copyWith(isSigningOut: false));
    }
  }

  /// Leaves guest mode so the user can sign in properly.
  Future<void> exitGuestMode() => _preferences.setGuest(false);
}
