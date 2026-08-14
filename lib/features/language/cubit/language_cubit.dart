import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/locale_cubit.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/language_model.dart';
import '../../../data/repositories/language_repository.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(this._repository, this._preferences, this._locale)
      : super(const LanguageState());

  final LanguageRepository _repository;
  final AppPreferences _preferences;

  /// Applying the new language is part of saving it, so it happens here rather
  /// than being left to each caller to remember.
  final LocaleCubit _locale;

  Future<void> loadLanguages() async {
    emit(state.copyWith(status: LanguageStatus.loading));
    try {
      final languages = await _repository.getLanguages();
      emit(state.copyWith(
        status: LanguageStatus.loaded,
        languages: languages,
        selectedCode: _preferences.selectedLanguage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LanguageStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  void selectLanguage(String code) {
    emit(state.copyWith(selectedCode: code));
  }

  /// Persists the selection on the backend and locally. Returns true on
  /// success; on failure [LanguageState.errorMessage] holds the reason.
  Future<bool> confirmSelection() async {
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.selectLanguage(state.selectedCode);
      await _preferences.setSelectedLanguage(state.selectedCode);
      _locale.setLanguage(state.selectedCode);
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: friendlyErrorMessage(e),
      ));
      return false;
    }
  }
}
