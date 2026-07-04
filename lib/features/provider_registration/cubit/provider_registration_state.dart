part of 'provider_registration_cubit.dart';

enum ProviderRegistrationStatus { initial, submitting, submitted, error }

class ProviderRegistrationState extends Equatable {
  const ProviderRegistrationState({
    this.status = ProviderRegistrationStatus.initial,
    this.step = 0,
    this.form = const ProviderRegistrationModel(
      businessName: '',
      serviceCategory: 'Cleaning',
      contactNumber: '',
      serviceArea: '',
      tradeLicenseUploaded: false,
      idDocumentUploaded: false,
    ),
    this.errorMessage,
  });

  final ProviderRegistrationStatus status;
  final int step;
  final ProviderRegistrationModel form;
  final String? errorMessage;

  bool get canContinue =>
      form.businessName.trim().isNotEmpty &&
      form.contactNumber.trim().isNotEmpty &&
      form.serviceArea.trim().isNotEmpty;

  bool get canSubmit => form.tradeLicenseUploaded && form.idDocumentUploaded;

  ProviderRegistrationState copyWith({
    ProviderRegistrationStatus? status,
    int? step,
    ProviderRegistrationModel? form,
    String? errorMessage,
  }) {
    return ProviderRegistrationState(
      status: status ?? this.status,
      step: step ?? this.step,
      form: form ?? this.form,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, step, form, errorMessage];
}
