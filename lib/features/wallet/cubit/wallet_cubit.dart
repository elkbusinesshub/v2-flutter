import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/wallet_repository.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository, this._preferences) : super(const WalletState());

  final WalletRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadWallet() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: WalletStatus.guest));
      return;
    }
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final summary = await _repository.getWalletSummary();
      emit(state.copyWith(status: WalletStatus.loaded, summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  Future<String> addMoney(double amount) =>
      _mutate(() => _repository.addMoney(amount), L10n.current.walletToppedUp);

  Future<String> withdraw(double amount) =>
      _mutate(() => _repository.withdraw(amount), L10n.current.walletWithdrawSuccess);

  /// Both mutations log a transaction server-side, so the summary is refetched
  /// instead of patching the balance — otherwise the history would go stale.
  /// Returns the message to show the user.
  Future<String> _mutate(Future<double> Function() call, String successMessage) async {
    if (state.summary == null) return L10n.current.walletStillLoading;
    emit(state.copyWith(isProcessing: true));
    try {
      await call();
      await _refreshSummary();
      emit(state.copyWith(isProcessing: false));
      return successMessage;
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
      return friendlyErrorMessage(e);
    }
  }

  /// A failed refetch must not blank out a wallet whose mutation succeeded —
  /// the stale summary stays until the next successful load.
  Future<void> _refreshSummary() async {
    try {
      final summary = await _repository.getWalletSummary();
      emit(state.copyWith(status: WalletStatus.loaded, summary: summary));
    } catch (_) {
      // Ignored on purpose: the mutation itself already succeeded.
    }
  }
}
