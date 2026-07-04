import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._preferences) : super(const AuthState()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<OtpRequested>(_onOtpRequested);
    on<OtpResendRequested>(_onOtpRequested);
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<EditPhoneNumberRequested>(_onEditPhoneNumberRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GuestSignInRequested>(_onGuestSignInRequested);
  }

  final AuthRepository _repository;
  final AppPreferences _preferences;

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
      final seconds = await _repository.requestOtp(state.phoneNumber);
      emit(state.copyWith(
        status: AuthStatus.initial,
        step: AuthStep.otpVerification,
        otp: '',
        resendCountdown: seconds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
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
        phoneNumber: state.phoneNumber,
        otp: state.otp,
      );
      await _completeSignIn(user);
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
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

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.inProgress, errorMessage: null));
    try {
      final user = await _repository.signInWithGoogle();
      await _completeSignIn(user);
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGuestSignInRequested(
    GuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.inProgress, errorMessage: null));
    try {
      final user = await _repository.continueAsGuest();
      await _completeSignIn(user);
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _completeSignIn(UserModel user) async {
    await _preferences.setAuthenticated(true);
    await _preferences.setUserName(user.name);
  }
}
