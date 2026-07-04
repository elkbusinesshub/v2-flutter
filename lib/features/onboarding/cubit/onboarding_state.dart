part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  const OnboardingState({this.pageIndex = 0, this.completed = false});

  final int pageIndex;
  final bool completed;

  OnboardingState copyWith({int? pageIndex, bool? completed}) =>
      OnboardingState(
        pageIndex: pageIndex ?? this.pageIndex,
        completed: completed ?? this.completed,
      );

  @override
  List<Object?> get props => [pageIndex, completed];
}
