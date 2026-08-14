part of 'seller_listings_cubit.dart';

enum SellerListingsStatus { initial, loading, success, error }

class SellerListingsState extends Equatable {
  const SellerListingsState({
    this.status = SellerListingsStatus.initial,
    this.ads = const [],
    this.tab,
    this.isSaving = false,
    this.errorMessage,
  });

  final SellerListingsStatus status;
  final List<AdModel> ads;

  /// Null is the "All" tab.
  final AdStatus? tab;

  /// True while the "Post a new ad" sheet is submitting.
  final bool isSaving;

  final String? errorMessage;

  List<AdModel> get visibleAds =>
      tab == null ? ads : ads.where((a) => a.status == tab).toList();

  /// Counts for the tab chips, taken from the same list the rows come from —
  /// the fixture panel's hardcoded counts sat above permanently empty lists.
  int countOf(AdStatus? tab) =>
      tab == null ? ads.length : ads.where((a) => a.status == tab).length;

  SellerListingsState copyWith({
    SellerListingsStatus? status,
    List<AdModel>? ads,
    AdStatus? tab,
    bool clearTab = false,
    bool? isSaving,
    String? errorMessage,
  }) =>
      SellerListingsState(
        status: status ?? this.status,
        ads: ads ?? this.ads,
        tab: clearTab ? null : (tab ?? this.tab),
        isSaving: isSaving ?? this.isSaving,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, ads, tab, isSaving, errorMessage];
}
