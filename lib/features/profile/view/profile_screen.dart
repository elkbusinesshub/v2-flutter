import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onSignedOut,
    this.onWalletTap,
    this.onOffersTap,
    this.onNotificationsTap,
    this.onLanguageTap,
    this.onRateServiceTap,
    this.onBecomeProviderTap,
    this.onProviderDashboardTap,
  });

  final VoidCallback onSignedOut;
  final VoidCallback? onWalletTap;
  final VoidCallback? onOffersTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onRateServiceTap;
  final VoidCallback? onBecomeProviderTap;
  final VoidCallback? onProviderDashboardTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<ProfileCubit>().signOut();
    if (mounted) widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ProfileStatus.error || state.user == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            );
          }

          final user = state.user!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 24 + MediaQuery.of(context).padding.top, 20, 28),
                decoration: const BoxDecoration(gradient: AppColors.navyHeader),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          user.avatarInitials,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatTile(label: 'Bookings', value: '${user.bookingsCount}'),
                        _StatTile(label: 'Reward Points', value: '${user.rewardPoints}'),
                        _StatTile(label: 'Rating', value: '${user.rating} ★'),
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
                    const _SectionLabel('My Account'),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.account_balance_wallet_outlined,
                          colorHex: 0xFFE0F7F5,
                          label: 'Wallet',
                          onTap: widget.onWalletTap,
                        ),
                        _MenuTile(
                          icon: Icons.card_giftcard,
                          colorHex: 0xFFFEF8DC,
                          label: 'Offers & Rewards',
                          onTap: widget.onOffersTap,
                        ),
                        _MenuTile(
                          icon: Icons.notifications_none,
                          colorHex: 0xFFDBEAFE,
                          label: 'Notifications',
                          onTap: widget.onNotificationsTap,
                        ),
                        _MenuTile(
                          icon: Icons.language,
                          colorHex: 0xFFEDE9FE,
                          label: 'Language',
                          onTap: widget.onLanguageTap,
                        ),
                        _MenuTile(
                          icon: Icons.star_outline,
                          colorHex: 0xFFFEF2F2,
                          label: 'Rate a Service',
                          onTap: widget.onRateServiceTap,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Provider Tools'),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.storefront_outlined,
                          colorHex: 0xFFD1FAE5,
                          label: 'Become a Provider',
                          onTap: widget.onBecomeProviderTap,
                        ),
                        _MenuTile(
                          icon: Icons.dashboard_outlined,
                          colorHex: 0xFFE0F7F5,
                          label: 'Provider Dashboard',
                          onTap: widget.onProviderDashboardTap,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Support'),
                    _MenuCard(
                      children: const [
                        _MenuTile(
                          icon: Icons.help_outline,
                          colorHex: 0xFFD1FAE5,
                          label: 'Help & Support',
                        ),
                        _MenuTile(
                          icon: Icons.info_outline,
                          colorHex: 0xFFE0F7F5,
                          label: 'About ELK Business Hub',
                        ),
                        _MenuTile(
                          icon: Icons.description_outlined,
                          colorHex: 0xFFFEF8DC,
                          label: 'Terms & Privacy Policy',
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.logout,
                          colorHex: 0xFFFEF2F2,
                          iconColor: AppColors.danger,
                          label: 'Sign Out',
                          labelColor: AppColors.danger,
                          isLoading: state.isSigningOut,
                          onTap: _confirmSignOut,
                          showDivider: false,
                        ),
                      ],
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.colorHex,
    required this.label,
    this.iconColor,
    this.labelColor,
    this.onTap,
    this.isLoading = false,
    this.showDivider = true,
  });

  final IconData icon;
  final int colorHex;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: isLoading ? null : onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(colorHex),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.dark),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor ?? AppColors.dark,
            ),
          ),
          trailing: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.danger),
                  ),
                )
              : const Icon(Icons.chevron_right, color: AppColors.gray, size: 20),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border, indent: 14, endIndent: 14),
      ],
    );
  }
}
