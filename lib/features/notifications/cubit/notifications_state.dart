part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, loaded, guest, error }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.isMarkingRead = false,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final bool isMarkingRead;
  final String? errorMessage;

  bool get hasUnread => notifications.any((n) => n.isUnread);

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    bool? isMarkingRead,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      isMarkingRead: isMarkingRead ?? this.isMarkingRead,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, isMarkingRead, errorMessage];
}
