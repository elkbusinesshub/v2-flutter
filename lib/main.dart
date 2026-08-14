import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/api/token_storage.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push notifications. Wrapped because a device without Play Services, or an
  // iOS build with no GoogleService-Info.plist, must still run — it just gets
  // its notifications from the in-app list instead.
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  // Dates are formatted through intl in the user's language, which needs the
  // symbol data for every locale the app offers, not just the device's.
  await initializeDateFormatting();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferences = AppPreferences(sharedPreferences);

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    onSessionExpired: () {
      preferences.setAuthenticated(false);
      redirectToLogin();
    },
  );

  // Serves the repositories that still run on fixture data; removed once the
  // last of them migrates to the live ApiClient.

  runApp(App(
    preferences: preferences,
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  ));
}
