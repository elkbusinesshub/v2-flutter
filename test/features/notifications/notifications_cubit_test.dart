import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/notification_models.dart';
import 'package:elk/data/repositories/notifications_repository.dart';
import 'package:elk/features/notifications/cubit/notifications_cubit.dart';

NotificationModel _notification(String id, {required bool isUnread}) =>
    NotificationModel(
      id: id,
      icon: '🧹',
      colorHex: 0xffe0f7f5,
      title: 'Booking confirmed',
      message: 'Your Home Cleaning is confirmed for Fri 31, 10:00.',
      time: '2h ago',
      isUnread: isUnread,
    );

class _FakeNotificationsRepository implements NotificationsRepository {
  List<NotificationModel> notifications = [
    _notification('1', isUnread: true),
    _notification('2', isUnread: true),
    _notification('3', isUnread: false),
  ];

  Object? listError;
  Object? markError;
  final List<String> calls = [];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    calls.add('list');
    if (listError != null) throw listError!;
    return notifications;
  }

  @override
  Future<void> markAllRead() async {
    calls.add('mark-all-read');
    if (markError != null) throw markError!;
    notifications = [
      for (final n in notifications) n.copyWith(isUnread: false),
    ];
  }

  // Push registration is not the cubit's concern — it is driven by the FCM
  // token callback, so these only need to exist for the interface.
  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    calls.add('register-device:$platform');
  }

  @override
  Future<void> unregisterDevice(String token) async {
    calls.add('unregister-device');
  }
}

void main() {
  late _FakeNotificationsRepository repository;

  Future<NotificationsCubit> buildCubit({
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return NotificationsCubit(repository, preferences);
  }

  setUp(() => repository = _FakeNotificationsRepository());

  test('loads notifications and flags the unread ones', () async {
    final cubit = await buildCubit();
    await cubit.loadNotifications();

    expect(cubit.state.status, NotificationsStatus.loaded);
    expect(cubit.state.notifications, hasLength(3));
    expect(cubit.state.hasUnread, isTrue);
  });

  test('guest mode short-circuits before hitting the API', () async {
    repository.listError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadNotifications();

    expect(cubit.state.status, NotificationsStatus.guest);
    expect(repository.calls, isEmpty);
  });

  test('mark-all-read calls the API then reloads from the server', () async {
    final cubit = await buildCubit();
    await cubit.loadNotifications();

    final message = await cubit.markAllRead();
    expect(message, 'Marked all read');
    expect(repository.calls, ['list', 'mark-all-read', 'list']);
    expect(cubit.state.hasUnread, isFalse);
    expect(cubit.state.isMarkingRead, isFalse);
  });

  test('a failed mark-all-read leaves the badges alone', () async {
    final cubit = await buildCubit();
    await cubit.loadNotifications();
    repository.markError =
        const ApiException(ApiErrorType.network, 'No internet connection.');

    final message = await cubit.markAllRead();
    expect(message, contains('internet'));
    // The unread badges must survive — previously they were cleared locally
    // regardless of whether the call succeeded.
    expect(cubit.state.hasUnread, isTrue);
    expect(cubit.state.isMarkingRead, isFalse);
  });

  test('an empty inbox loads cleanly with nothing unread', () async {
    repository.notifications = [];
    final cubit = await buildCubit();
    await cubit.loadNotifications();

    expect(cubit.state.status, NotificationsStatus.loaded);
    expect(cubit.state.notifications, isEmpty);
    expect(cubit.state.hasUnread, isFalse);
  });

  test('surfaces a friendly error when the list fails', () async {
    repository.listError =
        const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.loadNotifications();

    expect(cubit.state.status, NotificationsStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });

  test('NotificationModel parses the backend payload', () {
    final model = NotificationModel.fromJson({
      'id': '019fac2a-…',
      'icon': '💳',
      'colorHex': 0xffd1fae5,
      'title': 'Wallet topped up',
      'message': '₹500 was added to your ELK Wallet.',
      'time': 'Just now',
      'isUnread': true,
    });

    expect(model.icon, '💳');
    expect(model.isUnread, isTrue);
    expect(model.time, 'Just now');
  });
}
