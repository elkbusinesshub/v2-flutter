import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<NotificationModel>> getNotifications() {
    return _client.simulate(
      '/notifications',
      () => dummyNotificationsJson
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }

  Future<void> markAllRead() {
    return _client.simulateMutation('/notifications/mark-all-read', {}, () {});
  }
}
