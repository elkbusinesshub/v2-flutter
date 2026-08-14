import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/notification_models.dart';

/// In-app notifications and this device's push registration.
///
/// Backend contract:
///  * `GET    /notifications` → the user's notifications, newest first
///  * `POST   /notifications/mark-all-read` → clears every unread flag
///  * `POST   /notifications/devices { token, platform }` → push registration
///  * `DELETE /notifications/devices { token }` → stop pushing to this device
///
/// `POST /notifications` exists but is ADMIN-only — notifications are raised
/// by ops or other backend modules, never by the app.
class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _client.get(ApiEndpoints.notifications);
    return (data as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    await _client.post(ApiEndpoints.notificationsMarkAllRead);
  }

  /// Claims [token] for the signed-in user so their notifications reach this
  /// device. Registering the same token again is safe — the backend upserts,
  /// which is also how a handset that changed owner moves across.
  ///
  /// [platform] must be one of `ANDROID`, `IOS`, `WEB`.
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    await _client.post(
      ApiEndpoints.notificationDevices,
      data: {'token': token, 'platform': platform},
    );
  }

  /// Releases this device's token on sign-out. Scoped to the caller, so the
  /// user's other devices keep receiving notifications.
  Future<void> unregisterDevice(String token) async {
    await _client.delete(
      ApiEndpoints.notificationDevices,
      data: {'token': token},
    );
  }
}
