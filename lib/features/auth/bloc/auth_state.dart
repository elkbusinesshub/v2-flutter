part of 'auth_bloc.dart';

enum AuthStep { phoneEntry, otpVerification }

enum AuthStatus { initial, inProgress, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.step = AuthStep.phoneEntry,
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.otp = '',
    this.resendCountdown = 0,
    this.errorMessage,
    this.user,
  });

  final AuthStep step;
  final AuthStatus status;
  final String phoneNumber;
  final String otp;
  final int resendCountdown;
  final String? errorMessage;
  final UserModel? user;

  bool get isPhoneValid => phoneNumber.trim().length >= 7;

  bool get isOtpComplete => otp.length == 4;

  bool get isLoading => status == AuthStatus.inProgress;

  AuthState copyWith({
    AuthStep? step,
    AuthStatus? status,
    String? phoneNumber,
    String? otp,
    int? resendCountdown,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      step: step ?? this.step,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        phoneNumber,
        otp,
        resendCountdown,
        errorMessage,
        user,
      ];
}
