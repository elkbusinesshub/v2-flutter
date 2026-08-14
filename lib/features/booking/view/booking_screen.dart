import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/location_picker_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/booking_models.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/booking_bloc.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.serviceId,
    required this.onProceedToPayment,
  });

  final String serviceId;
  final VoidCallback onProceedToPayment;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  PickedLocation? _pickedAddress;

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(BookingDetailsRequested(widget.serviceId));
  }

  Future<void> _changeAddress() async {
    final picked = await showLocationPicker(
      context,
      selectedId: _pickedAddress?.id,
      title: l10n.chooseServiceAddress,
    );
    if (picked != null && mounted) {
      setState(() => _pickedAddress = picked);
      // The bloc needs the address too — the backend rejects empty ones.
      context.read<BookingBloc>().add(BookingAddressSelected(
            picked.address,
            lat: picked.lat,
            lng: picked.lng,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.bookService),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listenWhen: (previous, current) =>
            previous.step != current.step && current.step == BookingStep.payment,
        listener: (context, state) => widget.onProceedToPayment(),
        builder: (context, state) {
          if (state.status == BookingStatus.guest) {
            return SignInRequiredView(
              message: l10n.bookingSignInPrompt,
            );
          }
          if (state.status == BookingStatus.error) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context
                  .read<BookingBloc>()
                  .add(BookingDetailsRequested(widget.serviceId)),
            );
          }
          if (state.status == BookingStatus.loading || state.details == null) {
            return const LoadingView();
          }

          final details = state.details!;
          final pricing = details.pricing;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      details.serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.selectDateTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: details.dates.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final date = details.dates[index];
                          final selected = state.selectedDate?.day == date.day;
                          return GestureDetector(
                            onTap: () => context
                                .read<BookingBloc>()
                                .add(BookingDateSelected(date)),
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.teal : Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: selected ? AppColors.teal : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: selected ? Colors.white : AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    date.weekday,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AppColors.gray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.selectTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: details.timeSlots.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.4,
                      ),
                      itemBuilder: (context, index) {
                        final slot = details.timeSlots[index];
                        final selected = state.selectedTime?.time == slot.time;
                        return GestureDetector(
                          onTap: slot.available
                              ? () => context
                                  .read<BookingBloc>()
                                  .add(BookingTimeSelected(slot))
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !slot.available
                                  ? AppColors.grayLight
                                  : selected
                                      ? AppColors.teal
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: selected ? AppColors.teal : AppColors.border,
                              ),
                            ),
                            child: Text(
                              slot.time,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: !slot.available
                                    ? AppColors.gray.withValues(alpha: 0.5)
                                    : selected
                                        ? Colors.white
                                        : AppColors.dark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.serviceAddress,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _changeAddress,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppColors.teal, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.effectiveAddress.isEmpty
                                    ? l10n.tapChangeToChoose
                                    : state.effectiveAddress,
                                style: const TextStyle(fontSize: 13, color: AppColors.dark),
                              ),
                            ),
                            Text(
                              l10n.changeAction,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: _PriceBreakdown(pricing: pricing),
                    ),
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
                  label: l10n.proceedToPayment,
                  isLoading: state.status == BookingStatus.loading,
                  onPressed: state.canProceedToPayment
                      ? () => context
                          .read<BookingBloc>()
                          .add(const ProceedToPaymentRequested())
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

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.pricing});

  final PriceBreakdownModel pricing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _PriceRow(label: l10n.serviceFee, value: pricing.serviceFee),
        if (pricing.promoCode != null) ...[
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Promo (${pricing.promoCode})',
            value: -pricing.promoDiscount,
            valueColor: AppColors.success,
          ),
        ],
        const SizedBox(height: 12),
        const Divider(color: AppColors.border),
        const SizedBox(height: 4),
        _PriceRow(label: l10n.total, value: pricing.total, isTotal: true),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final sign = value < 0 ? '-' : '';
    final amount = value.abs().toStringAsFixed(0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isTotal ? AppColors.dark : AppColors.textSecondary,
          ),
        ),
        Text(
          '$sign₹$amount',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isTotal ? AppColors.dark : AppColors.dark),
          ),
        ),
      ],
    );
  }
}
