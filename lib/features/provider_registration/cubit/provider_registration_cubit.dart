import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'provider_registration_state.dart';

class ProviderRegistrationCubit extends Cubit<ProviderRegistrationState> {
  ProviderRegistrationCubit(this._repository) : super(const ProviderRegistrationState());

  final ProviderRepository _repository;

  void businessNameChanged(String value) =>
      emit(state.copyWith(form: state.form.copyWith(businessName: value)));

  void serviceCategoryChanged(String value) =>
      emit(state.copyWith(form: state.form.copyWith(serviceCategory: value)));

  void contactNumberChanged(String value) =>
      emit(state.copyWith(form: state.form.copyWith(contactNumber: value)));

  void serviceAreaChanged(String value) =>
      emit(state.copyWith(form: state.form.copyWith(serviceArea: value)));

  void uploadTradeLicense() =>
      emit(state.copyWith(form: state.form.copyWith(tradeLicenseUploaded: true)));

  void uploadIdDocument() =>
      emit(state.copyWith(form: state.form.copyWith(idDocumentUploaded: true)));

  void goToDocumentsStep() {
    if (!state.canContinue) return;
    emit(state.copyWith(step: 1));
  }

  void backToDetailsStep() => emit(state.copyWith(step: 0));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: ProviderRegistrationStatus.submitting));
    try {
      await _repository.submitRegistration(state.form);
      emit(state.copyWith(status: ProviderRegistrationStatus.submitted));
    } catch (e) {
      emit(state.copyWith(status: ProviderRegistrationStatus.error, errorMessage: e.toString()));
    }
  }
}
