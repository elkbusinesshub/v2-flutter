import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/provider_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/provider_schedule_cubit.dart';

class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({super.key, required this.onRegisterTap});

  /// Opens provider registration when the backend says there is no provider
  /// profile yet.
  final VoidCallback onRegisterTap;

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderScheduleCubit>().loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.mySchedule),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProviderScheduleCubit, ProviderScheduleState>(
        builder: (context, state) {
          if (state.status == ProviderScheduleStatus.loading ||
              state.status == ProviderScheduleStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ProviderScheduleStatus.guest) {
            return SignInRequiredView(
              message: l10n.providerSignInPrompt,
            );
          }
          if (state.status == ProviderScheduleStatus.notRegistered) {
            return RegistrationRequiredView(onRegister: widget.onRegisterTap);
          }
          if (state.status == ProviderScheduleStatus.error || state.schedule == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<ProviderScheduleCubit>().loadSchedule(),
            );
          }

          final schedule = state.schedule!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.tealPromo,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.event_available, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${schedule.todaysBookingsCount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l10n.todaysBookings,
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.availability,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final day in schedule.days) _DayCircle(day: day),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.todaysTimeSlots,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark),
              ),
              const SizedBox(height: 12),
              for (final slot in schedule.slots) _SlotTile(slot: slot),
            ],
          );
        },
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.day});

  final ScheduleDayModel day;

  @override
  Widget build(BuildContext context) {
    final bgColor = day.isToday
        ? AppColors.teal
        : day.available
            ? AppColors.tealLight
            : AppColors.grayLight;
    final textColor = day.isToday
        ? Colors.white
        : day.available
            ? AppColors.tealDark
            : AppColors.gray;

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              day.label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: day.available ? AppColors.success : AppColors.border,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});

  final ScheduleSlotModel slot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, bgColor, fgColor) = switch (slot.status) {
      ScheduleSlotStatus.active => (l10n.booked, AppColors.tealLight, AppColors.tealDark),
      ScheduleSlotStatus.pending => ('Pending', AppColors.yellowLight, const Color(0xFF8A6A00)),
      ScheduleSlotStatus.available => (l10n.available, AppColors.grayLight, AppColors.gray),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18, color: AppColors.gray),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              slot.timeRange,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fgColor),
            ),
          ),
        ],
      ),
    );
  }
}
