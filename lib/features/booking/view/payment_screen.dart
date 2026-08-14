import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/booking_bloc.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.onPaymentSuccess});

  final VoidCallback onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.sectionPayment),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.read<BookingBloc>().add(const BackToDateTimeRequested()),
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listenWhen: (previous, current) =>
            previous.step != current.step && current.step == BookingStep.confirmed,
        listener: (context, state) => onPaymentSuccess(),
        builder: (context, state) {
          final details = state.details;
          if (details == null) return const LoadingView();

          return Column(
            children: [
              Expanded(
                child: ListView(
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
                        children: [
                          Text(
                            l10n.amountToPay,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${details.pricing.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details.serviceName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.selectPaymentMethod,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.paymentMethods.map((method) {
                      final selected = state.selectedMethodId == method.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => context
                              .read<BookingBloc>()
                              .add(PaymentMethodSelected(method.id)),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: selected ? AppColors.teal : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(method.colorHex),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Center(
                                    child: Text(method.icon,
                                        style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method.subLabel,
                                        style: const TextStyle(
                                            fontSize: 11, color: AppColors.gray),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selected ? AppColors.teal : AppColors.border,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (state.status == BookingStatus.error) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? l10n.errorGeneric,
                        style: const TextStyle(fontSize: 12, color: AppColors.danger),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  14 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
                  ],
                ),
                child: PrimaryButton(
                  label: 'Pay ₹${details.pricing.total.toStringAsFixed(0)}',
                  isLoading: state.status == BookingStatus.processing,
                  onPressed: state.canSubmitPayment
                      ? () => context.read<BookingBloc>().add(const PaymentSubmitted())
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
