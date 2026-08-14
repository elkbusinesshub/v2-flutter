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

  /// Raw digits as typed in the phone field (national number, no prefix).
  final String phoneNumber;
  final String otp;
  final int resendCountdown;
  final String? errorMessage;
  final UserModel? user;

  /// Country dialing code shown in the phone field.
  static const countryCode = '+91';

  String get _digits => phoneNumber.replaceAll(RegExp(r'\D'), '');

  /// The backend requires E.164 (`+919876543210`).
  String get e164Phone => '$countryCode$_digits';

  bool get isPhoneValid => _digits.length == 10;

  /// Must match the backend: `OtpService.CODE_LENGTH` is 6 and `VerifyOtpDto`
  /// rejects anything that is not `^\d{6}$`.
  static const otpLength = 6;

  bool get isOtpComplete => otp.length == otpLength;

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
