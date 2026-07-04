import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/chat_models.dart';

class ChatRepository {
  ChatRepository(this._client);

  final ApiClient _client;

  Future<ChatThreadModel> getChatThread(String orderId) {
    return _client.simulate(
      '/orders/$orderId/chat',
      () => ChatThreadModel.fromJson(dummyChatThreadJson),
    );
  }

  /// Sends [text] and returns the persisted message echoed back by the server.
  Future<ChatMessageModel> sendMessage({
    required String orderId,
    required String text,
  }) {
    return _client.simulateMutation(
      '/orders/$orderId/chat',
      {'text': text},
      () => ChatMessageModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        time: _nowLabel(),
        isOutgoing: true,
      ),
      delay: const Duration(milliseconds: 300),
    );
  }

  String _nowLabel() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
