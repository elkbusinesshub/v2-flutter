import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_preferences.dart';
import 'buttons.dart';

/// Generic centered loading spinner used while a bloc is fetching data.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation(AppColors.teal),
      ),
    );
  }
}

/// Generic error state with retry action.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: PrimaryButton(
                  label: AppLocalizations.of(context).commonRetry,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown in place of content that needs a backend session while the user is
/// browsing as a guest. Signing in clears the guest flag and opens Login.
class SignInRequiredView extends StatelessWidget {
  const SignInRequiredView({super.key, this.message});

  /// Screen-specific prompt; falls back to the generic one.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.gray, size: 40),
            const SizedBox(height: 12),
            Text(
              message ?? l10n.signInRequired,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                label: l10n.signIn,
                onPressed: () async {
                  await context.read<AppPreferences>().setGuest(false);
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown on the provider screens when the user is signed in but has no
/// provider profile yet — the backend answers `403 No provider profile —
/// register first`, which is a prompt, not an error.
class RegistrationRequiredView extends StatelessWidget {
  const RegistrationRequiredView({super.key, required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, color: AppColors.gray, size: 40),
            const SizedBox(height: 12),
            Text(
              l10n.registerBusinessPrompt,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                label: l10n.becomeProvider,
                onPressed: onRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state placeholder.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.gray, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
