import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  final ChatRepository _repository;

  Future<void> loadThread(String orderId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final thread = await _repository.getChatThread(orderId);
      emit(state.copyWith(status: ChatStatus.loaded, thread: thread));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> sendMessage(String orderId, String text) async {
    final thread = state.thread;
    if (thread == null || text.trim().isEmpty) return;

    emit(state.copyWith(isSending: true));
    try {
      final message = await _repository.sendMessage(orderId: orderId, text: text.trim());
      emit(state.copyWith(
        isSending: false,
        thread: ChatThreadModel(
          contactName: thread.contactName,
          contactInitials: thread.contactInitials,
          contactStatus: thread.contactStatus,
          dateLabel: thread.dateLabel,
          messages: [...thread.messages, message],
        ),
      ));
    } catch (e) {
      emit(state.copyWith(isSending: false, errorMessage: e.toString()));
    }
  }
}
