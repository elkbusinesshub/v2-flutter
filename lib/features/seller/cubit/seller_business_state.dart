part of 'seller_business_cubit.dart';

enum SellerBusinessStatus {
  initial,
  loading,
  ready,

  /// The seller has listings but no business profile yet, so there is nothing
  /// to be available for and nothing earned. Not an error — the panel's other
  /// tabs work regardless.
  notRegistered,
  error,
}

class SellerBusinessState extends Equatable {
  const SellerBusinessState({
    this.status = SellerBusinessStatus.initial,
    this.businessName = '',
    this.isAvailable = false,
    this.earnings,
    this.schedule,
    this.isLoadingSchedule = false,
    this.errorMessage,
  });

  final SellerBusinessStatus status;
  final String businessName;

  /// Whether the seller is accepting work. Backed by the server, unlike the
  /// local flag the panel used to keep.
  final bool isAvailable;

  final EarningsSummaryModel? earnings;
  final ProviderScheduleModel? schedule;
  final bool isLoadingSchedule;
  final String? errorMessage;

  /// Whether the business panel has anything to show.
  bool get isRegistered => status == SellerBusinessStatus.ready;

  SellerBusinessState copyWith({
    SellerBusinessStatus? status,
    String? businessName,
    bool? isAvailable,
    EarningsSummaryModel? earnings,
    ProviderScheduleModel? schedule,
    bool? isLoadingSchedule,
    String? errorMessage,
  }) {
    return SellerBusinessState(
      status: status ?? this.status,
      businessName: businessName ?? this.businessName,
      isAvailable: isAvailable ?? this.isAvailable,
      earnings: earnings ?? this.earnings,
      schedule: schedule ?? this.schedule,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      // Cleared unless explicitly set, so a stale failure does not outlive the
      // action that caused it.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        businessName,
        isAvailable,
        earnings,
        schedule,
        isLoadingSchedule,
        errorMessage,
      ];
}
