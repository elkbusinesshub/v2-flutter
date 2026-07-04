import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification_models.dart';
import '../../../data/repositories/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(status: NotificationsStatus.loaded, notifications: notifications));
    } catch (e) {
      emit(state.copyWith(status: NotificationsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    emit(state.copyWith(
      notifications: [
        for (final notification in state.notifications) notification.copyWith(isUnread: false),
      ],
    ));
  }
}
