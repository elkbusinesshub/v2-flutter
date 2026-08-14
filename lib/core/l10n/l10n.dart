import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// The active translations, for the few places that must produce user-visible
/// text with no `BuildContext` to hand.
///
/// Cubits store `state.errorMessage` as a plain string, built inside a `catch`
/// far from the widget tree; `ApiException` does the same when it turns a
/// transport failure into something showable. Threading a context into both
/// would mean reshaping every cubit's error handling, so instead `App` keeps
/// this in sync from `MaterialApp.builder`, which reruns whenever the locale
/// changes.
///
/// Widgets must not use this — `AppLocalizations.of(context)` is correct there
/// and rebuilds properly.
abstract final class L10n {
  /// English until [App] mounts, so anything thrown during startup still reads.
  static AppLocalizations current = AppLocalizationsEn();
}
