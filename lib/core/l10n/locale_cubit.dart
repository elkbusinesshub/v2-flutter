import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_preferences.dart';

/// The locale the whole app renders in.
///
/// It owns the *choice* only. `LanguageCubit` is what persists a new language
/// (backend `PATCH /users/me/language` plus [AppPreferences]) and then pushes
/// it here; this cubit sits above `MaterialApp` so emitting rebuilds the entire
/// tree and every `AppLocalizations.of(context)` re-reads in the new language.
///
/// Seeded from [AppPreferences] so a restart comes back in the chosen language
/// before any network call has happened.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(AppPreferences preferences)
      : super(Locale(preferences.selectedLanguage));

  void setLanguage(String code) => emit(Locale(code));
}
