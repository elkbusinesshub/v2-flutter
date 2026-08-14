import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/chat_socket.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository, this._socket, this._preferences)
      : super(const ChatState());

  final ChatRepository _repository;
  final ChatSocket _socket;
  final AppPreferences _preferences;

  StreamSubscription<ChatMessageModel>? _messageSub;
  StreamSubscription<bool>? _connectionSub;

  Future<void> loadThread(String orderId) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ChatStatus.guest));
      return;
    }
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final thread = await _repository.getChatThread(orderId);
      emit(state.copyWith(status: ChatStatus.loaded, thread: thread));
      await _listenForLiveMessages(orderId);
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Joins the order's room and streams incoming messages in. Failing to
  /// connect is not fatal — the thread is already loaded and sending still
  /// works over HTTP, so the screen just reports realtime as unavailable.
  Future<void> _listenForLiveMessages(String orderId) async {
    _messageSub ??= _socket.messages.listen(_onLiveMessage);
    _connectionSub ??= _socket.connectionChanges
        .listen((connected) => emit(state.copyWith(isRealtimeConnected: connected)));
    try {
      await _socket.join(orderId);
    } catch (_) {
      emit(state.copyWith(isRealtimeConnected: false));
    }
  }

  /// The sender is in the room too, so their own message arrives back over the
  /// socket after the POST already appended it — hence the id check.
  void _onLiveMessage(ChatMessageModel message) {
    final thread = state.thread;
    if (thread == null) return;
    if (thread.messages.any((m) => m.id == message.id)) return;
    emit(state.copyWith(thread: _append(thread, message)));
  }

  /// Returns an error message, or `null` when the message was sent.
  Future<String?> sendMessage(String orderId, String text) async {
    final thread = state.thread;
    final trimmed = text.trim();
    if (thread == null || trimmed.isEmpty) return null;

    emit(state.copyWith(isSending: true));
    try {
      final message = await _repository.sendMessage(orderId: orderId, text: trimmed);
      final current = state.thread ?? thread;
      emit(state.copyWith(
        isSending: false,
        // The socket echo may have landed first; append only if it hasn't.
        thread: current.messages.any((m) => m.id == message.id)
            ? current
            : _append(current, message),
      ));
      return null;
    } catch (e) {
      emit(state.copyWith(isSending: false));
      return friendlyErrorMessage(e);
    }
  }

  ChatThreadModel _append(ChatThreadModel thread, ChatMessageModel message) =>
      ChatThreadModel(
        contactName: thread.contactName,
        contactInitials: thread.contactInitials,
        contactStatus: thread.contactStatus,
        dateLabel: thread.dateLabel,
        messages: [...thread.messages, message],
      );

  @override
  Future<void> close() async {
    await _messageSub?.cancel();
    await _connectionSub?.cancel();
    await _socket.dispose();
    return super.close();
  }
}
