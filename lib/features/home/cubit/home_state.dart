part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.feed,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeFeedModel? feed;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    HomeFeedModel? feed,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, feed, errorMessage];
}
