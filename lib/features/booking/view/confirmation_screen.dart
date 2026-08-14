import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/booking_bloc.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final confirmation = state.confirmation;
          if (confirmation == null) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.tealLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.tealDark, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.bookingConfirmedBang,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your booking has been placed successfully.\nYou will receive a confirmation shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.gray, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grayLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(label: l10n.bookingReference, value: confirmation.bookingReference),
                        const SizedBox(height: 10),
                        _DetailRow(label: l10n.lineService, value: confirmation.serviceName),
                        const SizedBox(height: 10),
                        _DetailRow(label: l10n.labelDateTime, value: confirmation.dateTimeLabel),
                        const SizedBox(height: 10),
                        _DetailRow(label: l10n.provider, value: confirmation.providerName),
                        const SizedBox(height: 10),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: l10n.amountPaid,
                          value: '₹${confirmation.amountPaid.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(label: l10n.commonDone, onPressed: onDone),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.gray),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}
