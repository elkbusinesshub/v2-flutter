import 'dart:async';

import '../../data/repositories/notifications_repository.dart';
import 'push_tokens.dart';

/// Keeps the backend's record of this device in step with who is signed in.
///
/// `POST /notifications/devices` and its DELETE have existed since Feature 21;
/// nothing called them, so the backend could store a notification and never
/// deliver it. This is the missing half.
///
/// Every method is best-effort. A device that cannot be registered still gets
/// its notifications in the in-app list — push is an extra channel, not the
/// record — so a failure here must never block signing in or, worse, signing
/// out.
class PushService {
  PushService(this._repository, this._tokens);

  final NotificationsRepository _repository;
  final PushTokens _tokens;

  StreamSubscription<String>? _refreshSubscription;

  /// The token currently registered, so [unregister] can release exactly it
  /// rather than asking for a fresh one at sign-out.
  String? _registered;

  /// Claims this device for the signed-in user. Safe to call repeatedly — the
  /// backend upserts.
  Future<void> register() async {
    try {
      if (!await _tokens.requestPermission()) return;

      final token = await _tokens.token();
      if (token == null) return;
      await _send(token);

      // FCM rotates tokens on reinstall and device restore. Without this the
      // backend would keep pushing to a token that no longer exists.
      _refreshSubscription ??= _tokens.refreshes.listen(_send);
    } catch (_) {
      // No Play Services, no APNs certificate, offline — all leave the user
      // with in-app notifications, which is the degradation we want.
    }
  }

  /// Releases this device at sign-out, so the next person to use the phone
  /// inherits none of the previous user's notifications.
  Future<void> unregister() async {
    await _refreshSubscription?.cancel();
    _refreshSubscription = null;

    final token = _registered;
    _registered = null;
    if (token == null) return;

    try {
      await _repository.unregisterDevice(token);
      // Dropped locally too: a token left alive would be re-registered to the
      // next account that signs in on this phone.
      await _tokens.delete();
    } catch (_) {
      // Sign-out must complete regardless. The backend prunes tokens FCM
      // rejects on the next send.
    }
  }

  Future<void> _send(String token) async {
    await _repository.registerDevice(token: token, platform: _tokens.platform);
    _registered = token;
  }
}
