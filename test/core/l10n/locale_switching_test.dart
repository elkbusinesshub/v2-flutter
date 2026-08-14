import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/l10n/l10n.dart';
import 'package:elk/core/l10n/locale_cubit.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/l10n/app_localizations.dart';

/// A miniature of the real `App`: LocaleCubit above MaterialApp, the same
/// delegates, and the same `builder` that keeps [L10n.current] in sync.
Widget _harness(LocaleCubit locale) {
  return BlocProvider.value(
    value: locale,
    child: BlocBuilder<LocaleCubit, Locale>(
      builder: (context, l) => MaterialApp(
        locale: l,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          L10n.current = AppLocalizations.of(context);
          return child!;
        },
        home: Builder(
          builder: (context) => Text(AppLocalizations.of(context).commonContinue),
        ),
      ),
    ),
  );
}

void main() {
  late AppPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    preferences = AppPreferences(await SharedPreferences.getInstance());
  });

  testWidgets('the whole tree re-renders when the language changes', (tester) async {
    final locale = LocaleCubit(preferences);
    addTearDown(locale.close);

    await tester.pumpWidget(_harness(locale));
    expect(find.text('Continue'), findsOneWidget);

    locale.setLanguage('ml');
    await tester.pumpAndSettle();

    // Screens already on screen must switch too — not only ones opened after.
    expect(find.text('Continue'), findsNothing);
    expect(find.text('തുടരുക'), findsOneWidget);
  });

  testWidgets('every advertised language resolves, none falls back to English',
      (tester) async {
    // config.constants.ts advertises these four; a missing .arb would silently
    // render English instead.
    const expected = {'en': 'Continue', 'hi': 'जारी रखें', 'ml': 'തുടരുക', 'ta': 'தொடரவும்'};

    for (final entry in expected.entries) {
      final locale = LocaleCubit(preferences);
      await tester.pumpWidget(_harness(locale));
      locale.setLanguage(entry.key);
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget, reason: entry.key);
      await locale.close();
    }
  });

  testWidgets('L10n.current follows the locale, so cubit-built errors translate',
      (tester) async {
    final locale = LocaleCubit(preferences);
    addTearDown(locale.close);

    await tester.pumpWidget(_harness(locale));
    expect(L10n.current.errorNoInternet, startsWith('No internet'));

    locale.setLanguage('hi');
    await tester.pumpAndSettle();
    expect(L10n.current.errorNoInternet, startsWith('इंटरनेट'));
  });

  test('the stored language is what the app starts in', () async {
    SharedPreferences.setMockInitialValues({'selected_language': 'ta'});
    final prefs = AppPreferences(await SharedPreferences.getInstance());

    expect(LocaleCubit(prefs).state, const Locale('ta'));
  });
}
