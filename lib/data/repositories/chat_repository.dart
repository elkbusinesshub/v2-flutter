import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/chat_models.dart';

/// Order chat over REST. The realtime fan-out lives in [ChatSocket].
///
/// Backend contract:
///  * `GET  /orders/:id/chat` → contact header + the full message list
///  * `POST /orders/:id/chat { text }` → the persisted message, which the
///    server also broadcasts to everyone in the order's room
///
/// Sending is deliberately HTTP, not a socket emit: persistence is the
/// server's job either way, and this keeps message delivery working when the
/// socket is down.
class ChatRepository {
  ChatRepository(this._client);

  final ApiClient _client;

  Future<ChatThreadModel> getChatThread(String orderId) async {
    final data = await _client.get(ApiEndpoints.orderChat(orderId));
    return ChatThreadModel.fromJson(data as Map<String, dynamic>);
  }

  /// Sends [text] and returns the persisted message echoed back by the server.
  Future<ChatMessageModel> sendMessage({
    required String orderId,
    required String text,
  }) async {
    final data = await _client.post(
      ApiEndpoints.orderChat(orderId),
      data: {'text': text},
    );
    return ChatMessageModel.fromJson(data as Map<String, dynamic>);
  }
}
