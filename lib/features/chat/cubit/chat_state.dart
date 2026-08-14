part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, loaded, guest, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.thread,
    this.isSending = false,
    this.isRealtimeConnected = false,
    this.errorMessage,
  });

  final ChatStatus status;
  final ChatThreadModel? thread;
  final bool isSending;

  /// Whether the `/chat` socket is up. Sending works either way — this only
  /// tells the user whether replies will arrive without reopening the thread.
  final bool isRealtimeConnected;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    ChatThreadModel? thread,
    bool? isSending,
    bool? isRealtimeConnected,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      isSending: isSending ?? this.isSending,
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, thread, isSending, isRealtimeConnected, errorMessage];
}
