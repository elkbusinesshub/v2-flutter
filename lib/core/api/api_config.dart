/// Compile-time API configuration.
///
/// The base URL can be overridden per environment without touching code:
///
///   flutter run --dart-define=API_BASE_URL=https://api.elkbusinesshub.com
///
/// The default points at the development machine's LAN IP so a physical
/// device on the same network can reach the local backend.
///
/// NOTE: that IP changes whenever the dev machine joins a different
/// network (it has already changed twice during integration). When the app
/// cannot reach the backend from a device, check `hostname -I` and either
/// update the default below or pass `--dart-define=API_BASE_URL=...`.
/// An emulator can use `http://10.0.2.2:3001` (Android) or
/// `http://localhost:3001` (iOS simulator/desktop) instead.
///
/// The API moved off port 3000 on 2026-08-13: `flutter run -d chrome` defaults
/// the web app to 3000, and the two cannot share it. The backend's `PORT` in
/// `elk-backend-v2/.env` must match the port here — it is 3001.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.167.40.13:3001',
  );

  /// Global prefix + URI version configured in the NestJS backend.
  static const String apiPath = '/api/v1';

  static const String apiBaseUrl = '$baseUrl$apiPath';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);
}
