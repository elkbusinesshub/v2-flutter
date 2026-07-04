part of 'elkstay_explore_cubit.dart';

enum ElkStayExploreStatus { initial, loading, success, error }

class ElkStayExploreState extends Equatable {
  const ElkStayExploreState({
    this.status = ElkStayExploreStatus.initial,
    this.stays = const [],
    this.activeCategory,
    this.verifiedOnly = false,
    this.priceFilter = false,
    this.singleRoomOnly = false,
    this.mealsIncluded = false,
    this.errorMessage,
  });

  final ElkStayExploreStatus status;
  final List<StayModel> stays;
  final StayCategoryType? activeCategory;
  final bool verifiedOnly;
  final bool priceFilter;
  final bool singleRoomOnly;
  final bool mealsIncluded;
  final String? errorMessage;

  String get titleLabel => activeCategory?.displayName ?? 'All Stays';
  int get countLabel => stays.length;

  ElkStayExploreState copyWith({
    ElkStayExploreStatus? status,
    List<StayModel>? stays,
    StayCategoryType? activeCategory,
    bool clearCategory = false,
    bool? verifiedOnly,
    bool? priceFilter,
    bool? singleRoomOnly,
    bool? mealsIncluded,
    String? errorMessage,
  }) =>
      ElkStayExploreState(
        status: status ?? this.status,
        stays: stays ?? this.stays,
        activeCategory: clearCategory ? null : activeCategory ?? this.activeCategory,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        priceFilter: priceFilter ?? this.priceFilter,
        singleRoomOnly: singleRoomOnly ?? this.singleRoomOnly,
        mealsIncluded: mealsIncluded ?? this.mealsIncluded,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        stays,
        activeCategory,
        verifiedOnly,
        priceFilter,
        singleRoomOnly,
        mealsIncluded,
        errorMessage,
      ];
}
