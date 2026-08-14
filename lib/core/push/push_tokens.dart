import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

/// The four things [PushService] needs from the device's push stack.
///
/// Split out so the registration logic can be tested without Firebase, which
/// needs a real platform channel and cannot run under `flutter test`.
abstract class PushTokens {
  /// Asks the user for notification permission. Returns false if refused —
  /// on Android 12 and below this is granted implicitly.
  Future<bool> requestPermission();

  /// This install's registration token, or null if the device cannot get one
  /// (no Play Services, no APNs token yet, permission refused).
  Future<String?> token();

  /// Fires when FCM rotates the token, which it does on reinstall, restore to
  /// a new device, and occasionally on its own.
  Stream<String> get refreshes;

  /// Drops the token so the next user of this phone inherits no pushes.
  Future<void> delete();

  /// `ANDROID` / `IOS` — the backend's `DevicePlatform` enum.
  String get platform;
}

class FirebasePushTokens implements PushTokens {
  FirebasePushTokens({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get refreshes => _messaging.onTokenRefresh;

  @override
  Future<void> delete() => _messaging.deleteToken();

  @override
  String get platform => Platform.isIOS ? 'IOS' : 'ANDROID';
}
