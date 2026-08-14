import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/push/push_service.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._preferences, {PushService? push})
      : _push = push,
        super(const AuthState()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<OtpRequested>(_onOtpRequested);
    on<OtpResendRequested>(_onOtpRequested);
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<EditPhoneNumberRequested>(_onEditPhoneNumberRequested);
    on<GuestSignInRequested>(_onGuestSignInRequested);
  }

  final AuthRepository _repository;
  final AppPreferences _preferences;

  /// Null in tests and wherever push is not wired; registration is skipped.
  final PushService? _push;

  void _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      phoneNumber: event.phoneNumber,
      errorMessage: null,
    ));
  }

  Future<void> _onOtpRequested(AuthEvent event, Emitter<AuthState> emit) async {
    if (!state.isPhoneValid) return;
    emit(state.copyWith(status: AuthStatus.inProgress, errorMessage: null));
    try {
      final seconds = await _repository.requestOtp(state.e164Phone);
      emit(state.copyWith(
        status: AuthStatus.initial,
        step: AuthStep.otpVerification,
        otp: '',
        resendCountdown: seconds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _friendlyMessage(e),
      ));
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(otp: event.otp, errorMessage: null));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isOtpComplete) return;
    emit(state.copyWith(status: AuthStatus.inProgress, errorMessage: null));
    try {
      final user = await _repository.verifyOtp(
        phoneNumber: state.e164Phone,
        otp: state.otp,
      );
      await _completeSignIn(user);
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _friendlyMessage(e),
      ));
    }
  }

  void _onEditPhoneNumberRequested(
    EditPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      step: AuthStep.phoneEntry,
      status: AuthStatus.initial,
      otp: '',
      errorMessage: null,
    ));
  }

  Future<void> _onGuestSignInRequested(
    GuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _repository.continueAsGuest();
    await _preferences.setGuest(true);
    await _preferences.setUserName(user.name);
    emit(state.copyWith(status: AuthStatus.success, user: user));
  }

  Future<void> _completeSignIn(UserModel user) async {
    await _preferences.setAuthenticated(true);
    await _preferences.setGuest(false);
    await _preferences.setUserName(user.name);
    await _preferences.setUserPhone(user.phone);
    // Claims this device for the user who just signed in. Best-effort inside
    // PushService, so a refused permission cannot fail the sign-in.
    await _push?.register();
  }

  String _friendlyMessage(Object error) => friendlyErrorMessage(error);
}
