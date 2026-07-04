import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/payment_models.dart';
import '../../../data/repositories/wallet_repository.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState());

  final WalletRepository _repository;

  Future<void> loadWallet() async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final summary = await _repository.getWalletSummary();
      emit(state.copyWith(status: WalletStatus.loaded, summary: summary));
    } catch (e) {
      emit(state.copyWith(status: WalletStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> addMoney(double amount) async {
    final summary = state.summary;
    if (summary == null) return;
    emit(state.copyWith(isProcessing: true));
    try {
      final balance = await _repository.addMoney(amount);
      emit(state.copyWith(
        isProcessing: false,
        summary: WalletSummaryModel(
          balance: balance,
          rewardPoints: summary.rewardPoints,
          transactions: summary.transactions,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
    }
  }

  Future<void> withdraw(double amount) async {
    final summary = state.summary;
    if (summary == null) return;
    emit(state.copyWith(isProcessing: true));
    try {
      final balance = await _repository.withdraw(amount);
      emit(state.copyWith(
        isProcessing: false,
        summary: WalletSummaryModel(
          balance: balance,
          rewardPoints: summary.rewardPoints,
          transactions: summary.transactions,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
    }
  }
}
