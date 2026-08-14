import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/location_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/addresses_cubit.dart';

/// Saved addresses — list, add, rename, set default, remove.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    context.read<AddressesCubit>().load();
  }

  Future<void> _report(Future<String?> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await action();
    if (error == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _addAddress() async {
    final result = await _addressSheet();
    if (result == null || !mounted) return;
    await _report(() => context
        .read<AddressesCubit>()
        .addAddress(label: result.label, line: result.line));
  }

  Future<void> _rename(AddressModel address) async {
    final result = await _addressSheet(initialLabel: address.label, labelOnly: true);
    if (result == null || !mounted) return;
    await _report(
        () => context.read<AddressesCubit>().rename(address.id, result.label));
  }

  Future<void> _confirmRemove(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeAddress),
        content: Text('Remove "${address.label}" from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.commonRemove, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _report(() => context.read<AddressesCubit>().remove(address.id));
  }

  /// Collects a label and (unless [labelOnly]) an address line. There is no
  /// maps picker yet, so the line is typed and pinned to a fixed coordinate.
  Future<({String label, String line})?> _addressSheet({
    String? initialLabel,
    bool labelOnly = false,
  }) {
    final labelController = TextEditingController(text: initialLabel ?? '');
    final lineController = TextEditingController();

    return showModalBottomSheet<({String label, String line})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        String? error;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelOnly ? l10n.renameAddress : l10n.addAnAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 16),
                _SheetField(
                  controller: labelController,
                  hint: l10n.addressLabelHint,
                  autofocus: true,
                ),
                if (!labelOnly) ...[
                  const SizedBox(height: 12),
                  _SheetField(
                    controller: lineController,
                    hint: l10n.addressLineHint,
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: labelOnly ? l10n.commonSave : l10n.addAddress,
                  onPressed: () {
                    final label = labelController.text.trim();
                    final line = lineController.text.trim();
                    // Mirrors the backend's @IsNotEmpty/@MaxLength(50 | 255).
                    if (label.isEmpty) {
                      setSheetState(() => error = l10n.enterALabel);
                      return;
                    }
                    if (label.length > 50) {
                      setSheetState(() => error = l10n.labelTooLong);
                      return;
                    }
                    if (!labelOnly && line.isEmpty) {
                      setSheetState(() => error = l10n.enterTheAddress);
                      return;
                    }
                    if (line.length > 255) {
                      setSheetState(() => error = l10n.addressTooLong);
                      return;
                    }
                    Navigator.pop(sheetContext, (label: label, line: line));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.grayLight,
      appBar: AppBar(
        title: Text(l10n.profileSavedAddresses),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, state) {
          switch (state.status) {
            case AddressesStatus.initial:
            case AddressesStatus.loading:
              return const LoadingView();
            case AddressesStatus.guest:
              return SignInRequiredView(
                message: l10n.addressesSignInPrompt,
              );
            case AddressesStatus.error:
              return ErrorRetryView(
                message: state.errorMessage ?? l10n.errorGeneric,
                onRetry: context.read<AddressesCubit>().load,
              );
            case AddressesStatus.loaded:
              return Column(
                children: [
                  Expanded(
                    child: state.addresses.isEmpty
                        ? EmptyStateView(
                            message: l10n.noSavedAddressesYet,
                            icon: Icons.location_on_outlined,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.addresses.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final address = state.addresses[index];
                              return _AddressTile(
                                address: address,
                                busy: state.busyId == address.id,
                                onSetDefault: () => _report(() => context
                                    .read<AddressesCubit>()
                                    .setDefault(address.id)),
                                onRename: () => _rename(address),
                                onRemove: () => _confirmRemove(address),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 16 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: PrimaryButton(
                      label: l10n.addAddress,
                      icon: Icons.add,
                      onPressed: _addAddress,
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.gray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
        style: const TextStyle(fontSize: 14, color: AppColors.dark),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.busy,
    required this.onSetDefault,
    required this.onRename,
    required this.onRemove,
  });

  final AddressModel address;
  final bool busy;
  final VoidCallback onSetDefault, onRename, onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: address.isDefault
            ? Border.all(color: AppColors.teal.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  address.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    l10n.defaultCaps,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.tealDark,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              address.formattedAddress,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    children: [
                      if (!address.isDefault)
                        TextButton(
                          onPressed: onSetDefault,
                          child: Text(l10n.setAsDefault,
                              style: TextStyle(fontSize: 12, color: AppColors.teal)),
                        ),
                      TextButton(
                        onPressed: onRename,
                        child: Text(l10n.rename,
                            style: TextStyle(fontSize: 12, color: AppColors.teal)),
                      ),
                      TextButton(
                        onPressed: onRemove,
                        child: Text(l10n.commonRemove,
                            style: TextStyle(fontSize: 12, color: AppColors.danger)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
