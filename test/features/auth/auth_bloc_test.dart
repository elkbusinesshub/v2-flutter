import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/user_model.dart';
import 'package:elk/data/repositories/auth_repository.dart';
import 'package:elk/features/auth/bloc/auth_bloc.dart';

const _user = UserModel(id: 'u1', name: 'Test User', phone: '+919876543210');

/// Scriptable in-memory stand-in for the real repository.
class _FakeAuthRepository implements AuthRepository {
  Object? requestOtpError;
  Object? verifyOtpError;
  String? lastRequestedPhone;
  String? lastVerifiedPhone;
  String? lastVerifiedOtp;

  @override
  Future<int> requestOtp(String phoneNumber) async {
    lastRequestedPhone = phoneNumber;
    if (requestOtpError != null) throw requestOtpError!;
    return 30;
  }

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    lastVerifiedPhone = phoneNumber;
    lastVerifiedOtp = otp;
    if (verifyOtpError != null) throw verifyOtpError!;
    return _user;
  }

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<bool> get hasSession async => false;

  @override
  Future<UserModel?> restoreSession() async => null;

  @override
  Future<void> logout() async {}

  @override
  UserModel continueAsGuest() =>
      const UserModel(id: 'guest', name: 'Guest User', phone: '');
}

void main() {
  late _FakeAuthRepository repository;
  late AppPreferences preferences;
  late AuthBloc bloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = _FakeAuthRepository();
    preferences = AppPreferences(await SharedPreferences.getInstance());
    bloc = AuthBloc(repository, preferences);
  });

  tearDown(() => bloc.close());

  group('OtpRequested', () {
    test('sends the E.164 phone and moves to OTP entry', () async {
      bloc
        ..add(const PhoneNumberChanged('9876543210'))
        ..add(const OtpRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>(
          (s) => s.step == AuthStep.otpVerification && s.resendCountdown == 30,
        )),
      );
      expect(repository.lastRequestedPhone, '+919876543210');
    });

    test('does nothing for an incomplete phone number', () async {
      bloc
        ..add(const PhoneNumberChanged('98765'))
        ..add(const OtpRequested());
      await Future<void>.delayed(Duration.zero);
      expect(repository.lastRequestedPhone, isNull);
      expect(bloc.state.step, AuthStep.phoneEntry);
    });

    test('surfaces the ApiException message on failure', () async {
      repository.requestOtpError = const ApiException(
        ApiErrorType.tooManyRequests,
        'Too many attempts. Please wait a moment and try again.',
      );
      bloc
        ..add(const PhoneNumberChanged('9876543210'))
        ..add(const OtpRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>(
          (s) =>
              s.status == AuthStatus.failure &&
              s.errorMessage == 'Too many attempts. Please wait a moment and try again.',
        )),
      );
    });
  });

  group('OtpSubmitted', () {
    test('signs in and persists the session flags', () async {
      bloc
        ..add(const PhoneNumberChanged('9876543210'))
        ..add(const OtpChanged('123456'))
        ..add(const OtpSubmitted());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>(
          (s) => s.status == AuthStatus.success && s.user == _user,
        )),
      );
      expect(repository.lastVerifiedPhone, '+919876543210');
      expect(repository.lastVerifiedOtp, '123456');
      expect(preferences.isAuthenticated, isTrue);
      expect(preferences.isGuest, isFalse);
      expect(preferences.userName, 'Test User');
    });

    test('shows the backend message for a wrong OTP', () async {
      repository.verifyOtpError = const ApiException(
        ApiErrorType.unauthorized,
        'Invalid or expired OTP',
      );
      bloc
        ..add(const PhoneNumberChanged('9876543210'))
        ..add(const OtpChanged('000000'))
        ..add(const OtpSubmitted());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>(
          (s) =>
              s.status == AuthStatus.failure &&
              s.errorMessage == 'Invalid or expired OTP',
        )),
      );
      expect(preferences.isAuthenticated, isFalse);
    });

    // Regression: the UI shipped four input boxes against a backend that
    // requires `^\d{6}$`, so every login failed 400 before reaching OtpService.
    test('refuses to submit a code shorter than the backend requires', () async {
      bloc
        ..add(const PhoneNumberChanged('9876543210'))
        ..add(const OtpChanged('1234'))
        ..add(const OtpSubmitted());
      await Future<void>.delayed(Duration.zero);

      expect(AuthState.otpLength, 6);
      expect(repository.lastVerifiedOtp, isNull);
      expect(preferences.isAuthenticated, isFalse);
    });
  });

  group('GuestSignInRequested', () {
    test('starts a local guest session without authentication', () async {
      bloc.add(const GuestSignInRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>(
          (s) => s.status == AuthStatus.success && s.user?.id == 'guest',
        )),
      );
      expect(preferences.isGuest, isTrue);
      expect(preferences.isAuthenticated, isFalse);
    });
  });
}
