part of 'provider_earnings_cubit.dart';

enum ProviderEarningsStatus { initial, loading, loaded, error }

class ProviderEarningsState extends Equatable {
  const ProviderEarningsState({
    this.status = ProviderEarningsStatus.initial,
    this.summary,
    this.errorMessage,
  });

  final ProviderEarningsStatus status;
  final EarningsSummaryModel? summary;
  final String? errorMessage;

  ProviderEarningsState copyWith({
    ProviderEarningsStatus? status,
    EarningsSummaryModel? summary,
    String? errorMessage,
  }) {
    return ProviderEarningsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
