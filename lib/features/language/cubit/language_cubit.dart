import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';
import '../../../data/models/language_model.dart';
import '../../../data/repositories/language_repository.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(this._repository, this._preferences)
      : super(const LanguageState());

  final LanguageRepository _repository;
  final AppPreferences _preferences;

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
        errorMessage: e.toString(),
      ));
    }
  }

  void selectLanguage(String code) {
    emit(state.copyWith(selectedCode: code));
  }

  Future<void> confirmSelection() async {
    await _repository.selectLanguage(state.selectedCode);
    await _preferences.setSelectedLanguage(state.selectedCode);
  }
}
