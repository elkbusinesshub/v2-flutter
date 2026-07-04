part of 'elkstay_home_cubit.dart';

enum ElkStayHomeStatus { initial, loading, success, error }

class ElkStayHomeState extends Equatable {
  const ElkStayHomeState({
    this.status = ElkStayHomeStatus.initial,
    this.feed,
    this.errorMessage,
  });

  final ElkStayHomeStatus status;
  final ElkStayHomeFeed? feed;
  final String? errorMessage;

  ElkStayHomeState copyWith({
    ElkStayHomeStatus? status,
    ElkStayHomeFeed? feed,
    String? errorMessage,
  }) =>
      ElkStayHomeState(
        status: status ?? this.status,
        feed: feed ?? this.feed,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, feed, errorMessage];
}
