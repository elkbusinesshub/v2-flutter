import 'package:equatable/equatable.dart';
import '../../../core/l10n/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/notification_models.dart';
import '../../../data/repositories/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository, this._preferences)
      : super(const NotificationsState());

  final NotificationsRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadNotifications() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: NotificationsStatus.guest));
      return;
    }
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Clears every unread flag server-side, then reloads so the list reflects
  /// what the server actually stored. Returns the message to show.
  ///
  /// Previously this awaited the call unguarded and then updated the list
  /// locally, so a failure both escaped the cubit and left the badges cleared.
  Future<String> markAllRead() async {
    emit(state.copyWith(isMarkingRead: true));
    try {
      await _repository.markAllRead();
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
        isMarkingRead: false,
      ));
      return L10n.current.markedAllRead;
    } catch (e) {
      emit(state.copyWith(isMarkingRead: false));
      return friendlyErrorMessage(e);
    }
  }
}
