import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/provider_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/provider_dashboard_cubit.dart';


/// Runs a cubit mutation and reports its failure message. Without this the
/// availability toggle and accept/decline failed silently.
Future<void> _reportIfFailed(
  BuildContext context,
  Future<String?> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await action();
  if (error == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(error)));
}

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({
    super.key,
    required this.onRegisterTap,
    this.onScheduleTap,
    this.onEarningsTap,
  });

  /// Opens provider registration when the backend says there is no
  /// provider profile yet.
  final VoidCallback onRegisterTap;

  final VoidCallback? onScheduleTap;
  final VoidCallback? onEarningsTap;

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      body: BlocBuilder<ProviderDashboardCubit, ProviderDashboardState>(
        builder: (context, state) {
          if (state.status == ProviderDashboardStatus.loading ||
              state.status == ProviderDashboardStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ProviderDashboardStatus.guest) {
            return SignInRequiredView(
              message: l10n.providerSignInPrompt,
            );
          }
          if (state.status == ProviderDashboardStatus.notRegistered) {
            return RegistrationRequiredView(onRegister: widget.onRegisterTap);
          }
          if (state.status == ProviderDashboardStatus.error || state.dashboard == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<ProviderDashboardCubit>().loadDashboard(),
            );
          }

          final dashboard = state.dashboard!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 24 + MediaQuery.of(context).padding.top, 20, 24),
                decoration: const BoxDecoration(gradient: AppColors.providerHeader),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dashboard.businessName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  dashboard.modeLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dashboard.isAvailable ? l10n.available : l10n.offline,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Switch(
                              value: dashboard.isAvailable,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.teal,
                              onChanged: (_) => _reportIfFailed(
                                context,
                                context.read<ProviderDashboardCubit>().toggleAvailability,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final stat in dashboard.stats) _StatCard(stat: stat),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _QuickLinkCard(
                            icon: Icons.calendar_month,
                            label: l10n.stepSchedule,
                            onTap: widget.onScheduleTap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickLinkCard(
                            icon: Icons.account_balance_wallet_outlined,
                            label: l10n.earnings,
                            onTap: widget.onEarningsTap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.newRequests,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (dashboard.requests.isEmpty)
                      EmptyStateView(message: l10n.noNewRequestsNow)
                    else
                      for (final request in dashboard.requests)
                        _RequestCard(
                          request: request,
                          isResponding: state.respondingRequestId == request.id,
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ProviderStatModel stat;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stat.value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 2),
            Text(
              stat.trend,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: AppColors.tealDark, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.dark),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.isResponding});

  final ProviderRequestModel request;
  final bool isResponding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.serviceName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark),
                ),
              ),
              Text(
                '₹${request.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${request.customerName} · ${request.location}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            request.time,
            style: const TextStyle(fontSize: 11, color: AppColors.gray),
          ),
          const SizedBox(height: 12),
          if (request.status == ProviderRequestStatus.pending)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: isResponding
                          ? null
                          : () => _reportIfFailed(
                              context,
                              () => context
                                  .read<ProviderDashboardCubit>()
                                  .respondToRequest(request, accept: false),
                            ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(l10n.decline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: isResponding
                          ? null
                          : () => _reportIfFailed(
                              context,
                              () => context
                                  .read<ProviderDashboardCubit>()
                                  .respondToRequest(request, accept: true),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: isResponding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(l10n.accept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: request.status == ProviderRequestStatus.accepted
                    ? AppColors.tealLight
                    : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                request.status == ProviderRequestStatus.accepted ? l10n.accepted : l10n.declined,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: request.status == ProviderRequestStatus.accepted
                      ? AppColors.tealDark
                      : AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
