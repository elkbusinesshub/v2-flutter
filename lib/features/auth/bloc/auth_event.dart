part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class PhoneNumberChanged extends AuthEvent {
  const PhoneNumberChanged(this.phoneNumber);

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class OtpRequested extends AuthEvent {
  const OtpRequested();
}

class OtpResendRequested extends AuthEvent {
  const OtpResendRequested();
}

class OtpChanged extends AuthEvent {
  const OtpChanged(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

class OtpSubmitted extends AuthEvent {
  const OtpSubmitted();
}

class EditPhoneNumberRequested extends AuthEvent {
  const EditPhoneNumberRequested();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class GuestSignInRequested extends AuthEvent {
  const GuestSignInRequested();
}
