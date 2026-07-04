part of 'splash_cubit.dart';

enum SplashDestination { onboarding, login, home }

class SplashState extends Equatable {
  const SplashState({this.destination});

  final SplashDestination? destination;

  @override
  List<Object?> get props => [destination];
}
