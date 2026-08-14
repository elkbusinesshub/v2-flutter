import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/l10n/locale_cubit.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/language_model.dart';
import 'package:elk/data/repositories/language_repository.dart';
import 'package:elk/features/language/cubit/language_cubit.dart';

const _languages = [
  LanguageModel(code: 'en', flag: '🇬🇧', name: 'English', nativeName: 'English (Default)'),
  LanguageModel(code: 'ml', flag: '🇮🇳', name: 'Malayalam', nativeName: 'മലയാളം'),
];

class _FakeLanguageRepository implements LanguageRepository {
  Object? getLanguagesError;
  Object? selectLanguageError;
  String? lastSelectedCode;

  @override
  Future<List<LanguageModel>> getLanguages() async {
    if (getLanguagesError != null) throw getLanguagesError!;
    return _languages;
  }

  @override
  Future<void> selectLanguage(String code) async {
    lastSelectedCode = code;
    if (selectLanguageError != null) throw selectLanguageError!;
  }
}

void main() {
  late _FakeLanguageRepository repository;
  late AppPreferences preferences;
  late LocaleCubit locale;
  late LanguageCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'selected_language': 'ml'});
    repository = _FakeLanguageRepository();
    preferences = AppPreferences(await SharedPreferences.getInstance());
    locale = LocaleCubit(preferences);
    cubit = LanguageCubit(repository, preferences, locale);
  });

  tearDown(() async {
    await cubit.close();
    await locale.close();
  });

  test('loadLanguages loads the list and preselects the stored language', () async {
    await cubit.loadLanguages();
    expect(cubit.state.status, LanguageStatus.loaded);
    expect(cubit.state.languages, _languages);
    expect(cubit.state.selectedCode, 'ml');
  });

  test('loadLanguages surfaces a friendly error', () async {
    repository.getLanguagesError = const ApiException(
      ApiErrorType.timeout,
      'The request timed out. Please try again.',
    );
    await cubit.loadLanguages();
    expect(cubit.state.status, LanguageStatus.error);
    expect(cubit.state.errorMessage, contains('timed out'));
  });

  test('confirmSelection persists on the backend and locally', () async {
    await cubit.loadLanguages();
    cubit.selectLanguage('en');
    final saved = await cubit.confirmSelection();
    expect(saved, isTrue);
    expect(repository.lastSelectedCode, 'en');
    expect(preferences.selectedLanguage, 'en');
    expect(cubit.state.isSaving, isFalse);
  });

  test('confirmSelection switches the locale the app renders in', () async {
    expect(locale.state, const Locale('ml'), reason: 'seeded from preferences');

    await cubit.loadLanguages();
    cubit.selectLanguage('ta');
    await cubit.confirmSelection();

    expect(locale.state, const Locale('ta'));
  });

  test('a failed save leaves the app in the language it was already in', () async {
    repository.selectLanguageError = const ApiException(
      ApiErrorType.network,
      'No internet connection. Please check your network and try again.',
    );
    await cubit.loadLanguages();
    cubit.selectLanguage('en');
    await cubit.confirmSelection();

    // Switching the UI to a language the backend never accepted would leave the
    // two disagreeing on the next launch.
    expect(locale.state, const Locale('ml'));
  });

  test('confirmSelection reports failure and keeps the local preference', () async {
    repository.selectLanguageError = const ApiException(
      ApiErrorType.network,
      'No internet connection. Please check your network and try again.',
    );
    await cubit.loadLanguages();
    cubit.selectLanguage('en');
    final saved = await cubit.confirmSelection();
    expect(saved, isFalse);
    expect(cubit.state.errorMessage, contains('internet'));
    expect(preferences.selectedLanguage, 'ml');
    expect(cubit.state.isSaving, isFalse);
  });
}
