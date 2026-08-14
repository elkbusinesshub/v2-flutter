import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/payment_models.dart';
import '../cubit/wallet_cubit.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallet();
  }

  /// Whether this tab was the visible one on the last dependency change.
  bool _wasVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Same reason as My Bookings: the nav branches stay mounted, so without
    // this the balance is whatever it was when the tab was first opened.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_wasVisible) {
      context.read<WalletCubit>().loadWallet();
    }
    _wasVisible = visible;
  }

  Future<void> _showAmountSheet({required bool isAddMoney}) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final cubit = context.read<WalletCubit>();

    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        String? error;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAddMoney ? l10n.walletAddMoneyTitle : l10n.walletWithdrawTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      hintText: '0.00',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                    style: const TextStyle(fontSize: 16, color: AppColors.dark),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(fontSize: 12, color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: isAddMoney ? l10n.walletAddMoney : l10n.walletWithdraw,
                  onPressed: () {
                    final value = double.tryParse(controller.text);
                    // Mirrors the backend's @IsPositive / @Max(1_000_000).
                    if (value == null || value <= 0) {
                      setSheetState(() => error = l10n.walletAmountTooSmall);
                      return;
                    }
                    if (value > 1000000) {
                      setSheetState(() => error = l10n.walletAmountTooLarge);
                      return;
                    }
                    Navigator.pop(sheetContext, value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (amount == null || !mounted) return;
    final message = isAddMoney ? await cubit.addMoney(amount) : await cubit.withdraw(amount);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.navWallet),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading || state.status == WalletStatus.initial) {
            return const LoadingView();
          }
          if (state.status == WalletStatus.guest) {
            return SignInRequiredView(message: l10n.walletSignInPrompt);
          }
          if (state.status == WalletStatus.error || state.summary == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<WalletCubit>().loadWallet(),
            );
          }

          final summary = state.summary!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.tealPromo,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.walletAvailableBalance,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${summary.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.card_giftcard, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            l10n.walletRewardPoints(summary.rewardPoints),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.walletAddMoney,
                      icon: Icons.add,
                      isLoading: state.isProcessing,
                      onPressed: () => _showAmountSheet(isAddMoney: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: l10n.walletWithdraw,
                      onPressed: state.isProcessing
                          ? null
                          : () => _showAmountSheet(isAddMoney: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.walletTransactionHistory,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < summary.transactions.length; i++)
                      _TransactionTile(
                        transaction: summary.transactions[i],
                        showDivider: i != summary.transactions.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.showDivider});

  final WalletTransactionModel transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(transaction.colorHex),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(transaction.icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.date,
                      style: const TextStyle(fontSize: 11, color: AppColors.gray),
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.isCredit ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: transaction.isCredit ? AppColors.success : AppColors.dark,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border, indent: 14, endIndent: 14),
      ],
    );
  }
}
