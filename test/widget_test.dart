import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/app.dart';
import 'package:elk/core/api/api_client.dart';
import 'package:elk/core/api/token_storage.dart';
import 'package:elk/core/utils/app_preferences.dart';

void main() {
  testWidgets('App builds and shows the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    final tokenStorage = TokenStorage();

    await tester.pumpWidget(App(
      preferences: preferences,
      apiClient: ApiClient(tokenStorage: tokenStorage),
      tokenStorage: tokenStorage,
    ));

    expect(find.text('BUSINESS HUB'), findsOneWidget);

    // Let the splash cubit's delayed navigation timer fire before the test ends.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
