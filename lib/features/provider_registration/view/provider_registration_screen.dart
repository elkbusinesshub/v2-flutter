import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/provider_registration_cubit.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ProviderRegistrationScreen> createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen> {
  static const _categories = [
    'Cleaning',
    'Taxi / Ride',
    'Car Rental',
    'Salon',
    'Porter',
    'Events',
    'Repair',
  ];

  late final TextEditingController _businessNameController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _serviceAreaController;

  @override
  void initState() {
    super.initState();
    final form = context.read<ProviderRegistrationCubit>().state.form;
    _businessNameController = TextEditingController(text: form.businessName);
    _contactNumberController = TextEditingController(text: form.contactNumber);
    _serviceAreaController = TextEditingController(text: form.serviceArea);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactNumberController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.becomeProvider),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProviderRegistrationCubit, ProviderRegistrationState>(
        builder: (context, state) {
          if (state.status == ProviderRegistrationStatus.error &&
              state.errorMessage != null) {
            // Previously dropped on the floor — a second application returns
            // 409 "You already have a provider profile".
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            });
          }
          if (state.status == ProviderRegistrationStatus.submitted) {
            return _SubmittedView(onDone: widget.onDone);
          }
          return state.step == 0 ? _buildDetailsStep(context, state) : _buildDocumentsStep(context, state);
        },
      ),
    );
  }

  Widget _buildDetailsStep(BuildContext context, ProviderRegistrationState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProviderRegistrationCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tellUsAboutBusiness,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.detailsForProfile,
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          _FieldLabel(l10n.businessName),
          _InputContainer(
            child: TextField(
              controller: _businessNameController,
              onChanged: cubit.businessNameChanged,
              decoration: InputDecoration(
                hintText: l10n.businessNameHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(l10n.serviceCategory),
          _InputContainer(
            child: DropdownButtonFormField<String>(
              initialValue: state.form.serviceCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                if (value != null) cubit.serviceCategoryChanged(value);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(l10n.contactNumber),
          _InputContainer(
            child: TextField(
              controller: _contactNumberController,
              keyboardType: TextInputType.phone,
              onChanged: cubit.contactNumberChanged,
              decoration: const InputDecoration(
                hintText: '98765 43210',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel(l10n.serviceArea),
          _InputContainer(
            child: TextField(
              controller: _serviceAreaController,
              onChanged: cubit.serviceAreaChanged,
              decoration: InputDecoration(
                hintText: l10n.serviceAreaHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l10n.commonContinue,
            onPressed: state.canContinue ? cubit.goToDocumentsStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(BuildContext context, ProviderRegistrationState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProviderRegistrationCubit>();
    final form = state.form;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.uploadDocuments,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.verifiedProvidersBlurb,
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          _DocumentUploadCard(
            icon: Icons.badge_outlined,
            title: l10n.tradeLicense,
            subtitle: l10n.tradeLicenseHint,
            isUploaded: form.tradeLicenseUploaded,
            onUpload: cubit.uploadTradeLicense,
          ),
          const SizedBox(height: 12),
          _DocumentUploadCard(
            icon: Icons.contact_page_outlined,
            title: l10n.idDocument,
            subtitle: l10n.idDocumentHint,
            isUploaded: form.idDocumentUploaded,
            onUpload: cubit.uploadIdDocument,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlineDarkButton(
                  label: l10n.commonBack,
                  onPressed: cubit.backToDetailsStep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: l10n.submitApplication,
                  isLoading: state.status == ProviderRegistrationStatus.submitting,
                  onPressed: state.canSubmit ? cubit.submit : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
      ),
    );
  }
}

class _InputContainer extends StatelessWidget {
  const _InputContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  const _DocumentUploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isUploaded,
    required this.onUpload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isUploaded;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.tealDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.dark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUploaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 14, color: AppColors.tealDark),
                  const SizedBox(width: 4),
                  Text(
                    l10n.uploaded,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark),
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: onUpload,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dark,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(l10n.upload, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  const _SubmittedView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.tealDark, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.applicationSubmitted,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.applicationReviewNote,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: l10n.commonDone, onPressed: onDone),
        ],
      ),
    );
  }
}
