import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/live_map_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/order_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/tracking_cubit.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.onChatTap,
    required this.onCancelled,
  });

  final String orderId;
  final VoidCallback onChatTap;
  final VoidCallback onCancelled;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    context.read<TrackingCubit>().loadTracking(widget.orderId);
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelOrder),
        content: Text(l10n.cancelOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.yesCancel, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final result = await context.read<TrackingCubit>().cancelOrder(widget.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
    // Only leave the screen when the order really was cancelled — a rejected
    // cancel used to navigate away as if it had succeeded.
    if (result.ok) widget.onCancelled();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.trackOrder),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (state.status == TrackingStatus.loading ||
              state.status == TrackingStatus.initial) {
            return const LoadingView();
          }
          if (state.status == TrackingStatus.guest) {
            return SignInRequiredView(
              message: l10n.trackSignInPrompt,
            );
          }
          if (state.status == TrackingStatus.error || state.tracking == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<TrackingCubit>().loadTracking(widget.orderId),
            );
          }

          final tracking = state.tracking!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.tealLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Center(
                              child: Text(tracking.serviceIcon,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tracking.serviceName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tracking.providerName,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          HighlightBadge(label: tracking.statusLabel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Where the job is, on a real map. Was a teal gradient with
                    // a map glyph — decoration, not a location. Older bookings
                    // carry no coordinate, so it falls back to that gradient.
                    if (tracking.lat != null && tracking.lng != null)
                      LiveMapView(
                        points: [
                          MapPoint(
                            lat: tracking.lat!,
                            lng: tracking.lng!,
                            kind: MapPointKind.place,
                            label: tracking.addressText,
                          ),
                        ],
                        height: 160,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      )
                    else
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.tealPromo,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Center(
                          child: Icon(Icons.map_outlined, color: Colors.white, size: 48),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.orderStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < tracking.steps.length; i++)
                            _TimelineStep(
                              step: tracking.steps[i],
                              isLast: i == tracking.steps.length - 1,
                            ),
                        ],
                      ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlineDarkButton(
                        label: l10n.chatWithProvider,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        onPressed: widget.onChatTap,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: state.isCancelling ? null : _confirmCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: state.isCancelling
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(AppColors.danger),
                                  ),
                                )
                              : Text(l10n.cancelOrder,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});

  final TrackingStepModel step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = step.status == TrackingStepStatus.done;
    final isActive = step.status == TrackingStepStatus.active;
    final circleColor = isDone || isActive ? AppColors.teal : AppColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.teal : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : isActive
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 36,
                  color: isDone ? AppColors.teal : AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    step.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: step.status == TrackingStepStatus.pending
                          ? AppColors.gray
                          : AppColors.dark,
                    ),
                  ),
                  Text(
                    step.time,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
