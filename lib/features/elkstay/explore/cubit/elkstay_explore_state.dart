part of 'elkstay_explore_cubit.dart';

enum ElkStayExploreStatus { initial, loading, success, error, guest }

class ElkStayExploreState extends Equatable {
  const ElkStayExploreState({
    this.status = ElkStayExploreStatus.initial,
    this.stays = const [],
    this.activeCategory,
    this.verifiedOnly = false,
    this.priceFilter = false,
    this.singleRoomOnly = false,
    this.mealsIncluded = false,
    this.roomTypeQuery = '',
    this.searchTerm = '',
    this.errorMessage,
  });

  final ElkStayExploreStatus status;
  final List<StayModel> stays;
  final StayCategoryType? activeCategory;
  final bool verifiedOnly;
  final bool priceFilter;
  final bool singleRoomOnly;
  final bool mealsIncluded;

  /// Explicit room-type query (e.g. `single`, `double`); empty when unset.
  final String roomTypeQuery;

  /// Free-text query sent to the backend (name / area / address).
  final String searchTerm;
  final String? errorMessage;

  String get titleLabel => activeCategory?.displayName ?? L10n.current.allStays;
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
    String? roomTypeQuery,
    String? searchTerm,
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
        roomTypeQuery: roomTypeQuery ?? this.roomTypeQuery,
        searchTerm: searchTerm ?? this.searchTerm,
        errorMessage: errorMessage,
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
        roomTypeQuery,
        searchTerm,
        errorMessage,
      ];
}
