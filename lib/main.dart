import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/app_preferences.dart';
import 'data/datasources/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferences = AppPreferences(sharedPreferences);
  final apiClient = ApiClient();

  runApp(App(preferences: preferences, apiClient: apiClient));
}
