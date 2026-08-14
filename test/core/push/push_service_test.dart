import 'dart:async';

import 'package:elk/core/push/push_service.dart';
import 'package:elk/core/push/push_tokens.dart';
import 'package:elk/data/models/notification_models.dart';
import 'package:elk/data/repositories/notifications_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  final List<(String, String)> registered = [];
  final List<String> unregistered = [];
  Object? error;

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    if (error != null) throw error!;
    registered.add((token, platform));
  }

  @override
  Future<void> unregisterDevice(String token) async {
    if (error != null) throw error!;
    unregistered.add(token);
  }

  @override
  Future<List<NotificationModel>> getNotifications() async => const [];

  @override
  Future<void> markAllRead() async {}
}

class _FakePushTokens implements PushTokens {
  bool granted = true;
  String? deviceToken = 'fcm-token-1';
  bool deleted = false;
  int permissionRequests = 0;
  final _refreshes = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return granted;
  }

  @override
  Future<String?> token() async => deviceToken;

  @override
  Stream<String> get refreshes => _refreshes.stream;

  @override
  Future<void> delete() async => deleted = true;

  @override
  String get platform => 'ANDROID';

  void rotate(String token) => _refreshes.add(token);
  Future<void> dispose() => _refreshes.close();
}

void main() {
  late _FakeNotificationsRepository repository;
  late _FakePushTokens tokens;
  late PushService service;

  setUp(() {
    repository = _FakeNotificationsRepository();
    tokens = _FakePushTokens();
    service = PushService(repository, tokens);
  });

  tearDown(() => tokens.dispose());

  group('register', () {
    test('claims the device for the signed-in user', () async {
      await service.register();

      expect(tokens.permissionRequests, 1);
      expect(repository.registered, [('fcm-token-1', 'ANDROID')]);
    });

    test('sends nothing when the user refuses notifications', () async {
      tokens.granted = false;

      await service.register();

      expect(repository.registered, isEmpty);
    });

    test('sends nothing when the device has no token', () async {
      // No Play Services, or APNs has not issued one yet.
      tokens.deviceToken = null;

      await service.register();

      expect(repository.registered, isEmpty);
    });

    test('re-registers when FCM rotates the token', () async {
      // Rotation happens on reinstall and device restore. Without this the
      // backend keeps pushing to a token that no longer exists.
      await service.register();

      tokens.rotate('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registered, [
        ('fcm-token-1', 'ANDROID'),
        ('fcm-token-2', 'ANDROID'),
      ]);
    });

    test('a failed registration does not throw into the sign-in', () async {
      // Push is an extra channel; the in-app list is the record. Failing here
      // must never cost the user their login.
      repository.error = Exception('offline');

      await expectLater(service.register(), completes);
    });
  });

  group('unregister', () {
    test('releases the token it registered and drops it locally', () async {
      await service.register();

      await service.unregister();

      expect(repository.unregistered, ['fcm-token-1']);
      expect(tokens.deleted, isTrue);
    });

    test('releases the rotated token, not the original', () async {
      await service.register();
      tokens.rotate('fcm-token-2');
      await Future<void>.delayed(Duration.zero);

      await service.unregister();

      expect(repository.unregistered, ['fcm-token-2']);
    });

    test('stops listening for rotations after sign-out', () async {
      await service.register();
      await service.unregister();

      tokens.rotate('fcm-token-3');
      await Future<void>.delayed(Duration.zero);

      // Registering the signed-out user's phone again would push the previous
      // account's notifications to whoever holds the handset next.
      expect(repository.registered, [('fcm-token-1', 'ANDROID')]);
    });

    test('does nothing when nothing was ever registered', () async {
      await service.unregister();

      expect(repository.unregistered, isEmpty);
      expect(tokens.deleted, isFalse);
    });

    test('a failed release still completes the sign-out', () async {
      await service.register();
      repository.error = Exception('offline');

      await expectLater(service.unregister(), completes);
    });
  });
}
