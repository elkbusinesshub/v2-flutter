import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
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
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: const Text('Become a Provider'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProviderRegistrationCubit, ProviderRegistrationState>(
        builder: (context, state) {
          if (state.status == ProviderRegistrationStatus.submitted) {
            return _SubmittedView(onDone: widget.onDone);
          }
          return state.step == 0 ? _buildDetailsStep(context, state) : _buildDocumentsStep(context, state);
        },
      ),
    );
  }

  Widget _buildDetailsStep(BuildContext context, ProviderRegistrationState state) {
    final cubit = context.read<ProviderRegistrationCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your business',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          const Text(
            "We'll use these details to set up your provider profile.",
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          _FieldLabel('Business Name'),
          _InputContainer(
            child: TextField(
              controller: _businessNameController,
              onChanged: cubit.businessNameChanged,
              decoration: const InputDecoration(
                hintText: 'e.g. Royal Shine Co.',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel('Service Category'),
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
          _FieldLabel('Contact Number'),
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
          _FieldLabel('Service Area'),
          _InputContainer(
            child: TextField(
              controller: _serviceAreaController,
              onChanged: cubit.serviceAreaChanged,
              decoration: const InputDecoration(
                hintText: 'e.g. Downtown Dubai',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Continue',
            onPressed: state.canContinue ? cubit.goToDocumentsStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(BuildContext context, ProviderRegistrationState state) {
    final cubit = context.read<ProviderRegistrationCubit>();
    final form = state.form;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload required documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verified providers get more bookings and customer trust.',
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          _DocumentUploadCard(
            icon: Icons.badge_outlined,
            title: 'Trade License',
            subtitle: 'Upload a clear photo or PDF of your trade license',
            isUploaded: form.tradeLicenseUploaded,
            onUpload: cubit.uploadTradeLicense,
          ),
          const SizedBox(height: 12),
          _DocumentUploadCard(
            icon: Icons.contact_page_outlined,
            title: 'ID Document',
            subtitle: 'Upload a government-issued photo ID',
            isUploaded: form.idDocumentUploaded,
            onUpload: cubit.uploadIdDocument,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlineDarkButton(
                  label: 'Back',
                  onPressed: cubit.backToDetailsStep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Submit Application',
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppColors.tealDark),
                  SizedBox(width: 4),
                  Text(
                    'Uploaded',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tealDark),
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
              child: const Text('Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
          const Text(
            'Application Submitted!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll review your details and verify your documents within 24-48 hours. "
            "You'll get a notification once your provider account is approved.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Done', onPressed: onDone),
        ],
      ),
    );
  }
}
