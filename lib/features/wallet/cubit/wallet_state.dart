part of 'wallet_cubit.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.summary,
    this.isProcessing = false,
    this.errorMessage,
  });

  final WalletStatus status;
  final WalletSummaryModel? summary;
  final bool isProcessing;
  final String? errorMessage;

  WalletState copyWith({
    WalletStatus? status,
    WalletSummaryModel? summary,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, isProcessing, errorMessage];
}
