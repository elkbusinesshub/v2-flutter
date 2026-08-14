import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onSignedOut,
    this.onWalletTap,
    this.onOffersTap,
    this.onNotificationsTap,
    this.onLanguageTap,
    this.onAddressesTap,
    this.onRateServiceTap,
    this.onBecomeProviderTap,
    this.onProviderDashboardTap,
  });

  final VoidCallback onSignedOut;
  final VoidCallback? onWalletTap;
  final VoidCallback? onOffersTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onAddressesTap;
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileSignOut),
        content: Text(l10n.profileSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.profileSignOut,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<ProfileCubit>().signOut();
    if (mounted) widget.onSignedOut();
  }

  Future<void> _showEditProfileSheet(UserModel user) async {
    final cubit = context.read<ProfileCubit>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _EditProfileSheet(user: user),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileUpdated)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.grayLight,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ProfileStatus.guest) {
            return _GuestView(
              onSignIn: () async {
                await context.read<ProfileCubit>().exitGuestMode();
                if (context.mounted) widget.onSignedOut();
              },
            );
          }
          if (state.status == ProfileStatus.error || state.user == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => _showEditProfileSheet(user),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          visualDensity: VisualDensity.compact,
                          tooltip: l10n.profileEdit,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatTile(label: l10n.navBookings, value: '${user.bookingsCount}'),
                        _StatTile(label: l10n.profileRewardPoints, value: '${user.rewardPoints}'),
                        _StatTile(label: l10n.profileRating, value: '${user.rating} ★'),
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
                    _SectionLabel(l10n.profileMyAccount),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.account_balance_wallet_outlined,
                          colorHex: 0xFFE0F7F5,
                          label: l10n.navWallet,
                          onTap: widget.onWalletTap,
                        ),
                        _MenuTile(
                          icon: Icons.card_giftcard,
                          colorHex: 0xFFFEF8DC,
                          label: l10n.profileOffersRewards,
                          onTap: widget.onOffersTap,
                        ),
                        _MenuTile(
                          icon: Icons.notifications_none,
                          colorHex: 0xFFDBEAFE,
                          label: l10n.profileNotifications,
                          onTap: widget.onNotificationsTap,
                        ),
                        _MenuTile(
                          icon: Icons.location_on_outlined,
                          colorHex: 0xFFE0F7F5,
                          label: l10n.profileSavedAddresses,
                          onTap: widget.onAddressesTap,
                        ),
                        _MenuTile(
                          icon: Icons.language,
                          colorHex: 0xFFEDE9FE,
                          label: l10n.profileLanguage,
                          onTap: widget.onLanguageTap,
                        ),
                        _MenuTile(
                          icon: Icons.star_outline,
                          colorHex: 0xFFFEF2F2,
                          label: l10n.profileRateService,
                          onTap: widget.onRateServiceTap,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(l10n.profileProviderTools),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.storefront_outlined,
                          colorHex: 0xFFD1FAE5,
                          label: l10n.becomeProvider,
                          onTap: widget.onBecomeProviderTap,
                        ),
                        _MenuTile(
                          icon: Icons.dashboard_outlined,
                          colorHex: 0xFFE0F7F5,
                          label: l10n.profileProviderDashboard,
                          onTap: widget.onProviderDashboardTap,
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(l10n.profileSupport),
                    _MenuCard(
                      children: [
                        _MenuTile(
                          icon: Icons.help_outline,
                          colorHex: 0xFFD1FAE5,
                          label: l10n.profileHelpSupport,
                        ),
                        _MenuTile(
                          icon: Icons.info_outline,
                          colorHex: 0xFFE0F7F5,
                          label: l10n.profileAbout,
                        ),
                        _MenuTile(
                          icon: Icons.description_outlined,
                          colorHex: 0xFFFEF8DC,
                          label: l10n.profileTermsPrivacy,
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
                          label: l10n.profileSignOut,
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

/// Shown on the profile tab while browsing as a guest — there is no backend
/// session, so instead of the profile we offer the way into one.
class _GuestView extends StatelessWidget {
  const _GuestView({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 56, color: AppColors.gray),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).profileGuestTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).profileGuestBody,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.gray),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: AppLocalizations.of(context).signIn,
              onPressed: onSignIn,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for editing name and email (`PATCH /users/me`).
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final UserModel user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validate(String name, String email) {
    final l10n = AppLocalizations.of(context);
    if (name.isEmpty) return l10n.profileNameRequired;
    if (name.length > 100) return l10n.profileNameTooLong;
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.profileEmailInvalid;
    }
    return null;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final validationError = _validate(name, email);
    setState(() => _validationError = validationError);
    if (validationError != null) return;

    final cubit = context.read<ProfileCubit>();
    final saved = await cubit.updateProfile(
      name: name,
      email: email.isEmpty ? null : email,
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      setState(() => _validationError = cubit.state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSaving = context
        .select((ProfileCubit cubit) => cubit.state.isSaving);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileEdit,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.profileNameLabel),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.profileEmailLabel),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 12),
            Text(
              _validationError!,
              style: const TextStyle(fontSize: 12, color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.commonSave,
            isLoading: isSaving,
            onPressed: isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}
