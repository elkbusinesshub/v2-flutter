import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/user_model.dart';
import 'package:elk/data/repositories/auth_repository.dart';
import 'package:elk/data/repositories/profile_repository.dart';
import 'package:elk/features/profile/cubit/profile_cubit.dart';

const _user = UserModel(
  id: 'u1',
  name: 'Test User',
  phone: '+919876543210',
  email: 'test@example.com',
  language: 'ml',
);

class _FakeProfileRepository implements ProfileRepository {
  Object? getProfileError;
  Object? updateProfileError;
  String? lastName;
  String? lastEmail;

  @override
  Future<UserModel> getProfile() async {
    if (getProfileError != null) throw getProfileError!;
    return _user;
  }

  @override
  Future<UserModel> updateProfile({String? name, String? email}) async {
    lastName = name;
    lastEmail = email;
    if (updateProfileError != null) throw updateProfileError!;
    return UserModel(
      id: _user.id,
      name: name ?? _user.name,
      phone: _user.phone,
      email: email ?? _user.email,
      language: _user.language,
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  bool loggedOut = false;

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  UserModel continueAsGuest() =>
      const UserModel(id: 'guest', name: 'Guest User', phone: '');

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<bool> get hasSession async => true;

  @override
  Future<int> requestOtp(String phoneNumber) async => 30;

  @override
  Future<UserModel?> restoreSession() async => _user;

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async =>
      _user;
}

void main() {
  late _FakeProfileRepository repository;
  late _FakeAuthRepository authRepository;
  late AppPreferences preferences;

  Future<ProfileCubit> buildCubit({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    preferences = AppPreferences(await SharedPreferences.getInstance());
    return ProfileCubit(repository, authRepository, preferences);
  }

  setUp(() {
    repository = _FakeProfileRepository();
    authRepository = _FakeAuthRepository();
  });

  group('loadProfile', () {
    test('loads the profile and syncs local name/language', () async {
      final cubit = await buildCubit();
      await cubit.loadProfile();
      expect(cubit.state.status, ProfileStatus.loaded);
      expect(cubit.state.user, _user);
      expect(preferences.userName, 'Test User');
      expect(preferences.selectedLanguage, 'ml');
    });

    test('emits guest status without calling the API in guest mode', () async {
      final cubit = await buildCubit(prefs: {'is_guest': true});
      repository.getProfileError = StateError('must not be called');
      await cubit.loadProfile();
      expect(cubit.state.status, ProfileStatus.guest);
    });

    test('surfaces a friendly error message on failure', () async {
      repository.getProfileError = const ApiException(
        ApiErrorType.network,
        'No internet connection. Please check your network and try again.',
      );
      final cubit = await buildCubit();
      await cubit.loadProfile();
      expect(cubit.state.status, ProfileStatus.error);
      expect(cubit.state.errorMessage, contains('internet'));
    });
  });

  group('updateProfile', () {
    test('saves and updates the on-screen user', () async {
      final cubit = await buildCubit();
      await cubit.loadProfile();
      final saved =
          await cubit.updateProfile(name: 'New Name', email: 'new@example.com');
      expect(saved, isTrue);
      expect(cubit.state.user?.name, 'New Name');
      expect(cubit.state.isSaving, isFalse);
      expect(preferences.userName, 'New Name');
      expect(repository.lastEmail, 'new@example.com');
    });

    test('keeps the current profile and reports the error on failure', () async {
      repository.updateProfileError = const ApiException(
        ApiErrorType.validation,
        'email must be an email',
      );
      final cubit = await buildCubit();
      await cubit.loadProfile();
      final saved = await cubit.updateProfile(name: 'New Name');
      expect(saved, isFalse);
      expect(cubit.state.user, _user);
      expect(cubit.state.status, ProfileStatus.loaded);
      expect(cubit.state.errorMessage, 'email must be an email');
    });
  });

  test('signOut logs out and clears session flags', () async {
    final cubit =
        await buildCubit(prefs: {'is_authenticated': true, 'is_guest': false});
    await cubit.signOut();
    expect(authRepository.loggedOut, isTrue);
    expect(preferences.isAuthenticated, isFalse);
    expect(cubit.state.isSigningOut, isFalse);
  });

  test('exitGuestMode clears the guest flag', () async {
    final cubit = await buildCubit(prefs: {'is_guest': true});
    await cubit.exitGuestMode();
    expect(preferences.isGuest, isFalse);
  });
}
