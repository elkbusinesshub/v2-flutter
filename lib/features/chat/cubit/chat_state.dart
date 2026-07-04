part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.thread,
    this.isSending = false,
    this.errorMessage,
  });

  final ChatStatus status;
  final ChatThreadModel? thread;
  final bool isSending;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    ChatThreadModel? thread,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, thread, isSending, errorMessage];
}
