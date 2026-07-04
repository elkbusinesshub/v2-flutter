import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk_business_hub/app.dart';
import 'package:elk_business_hub/core/utils/app_preferences.dart';
import 'package:elk_business_hub/data/datasources/api_client.dart';

void main() {
  testWidgets('App builds and shows the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());

    await tester.pumpWidget(App(preferences: preferences, apiClient: ApiClient()));

    expect(find.text('Business Hub'), findsOneWidget);

    // Let the splash cubit's delayed navigation timer fire before the test ends.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
