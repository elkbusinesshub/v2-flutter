import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/models/chat_models.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Realtime transport for order chat — the app's only Socket.IO connection.
///
/// Backend contract (`chat.gateway.ts`):
///  * namespace `/chat`, JWT in the handshake (`auth: { token }`); an
///    unauthenticated socket is disconnected before any handler runs
///  * `order:join` / `order:leave` with a booking id — rooms decide who
///    receives a thread's messages. The server confirms with `order:joined`
///    or refuses with `order:join:denied` when the order is not the caller's
///  * server → client `message`, carrying the same JSON shape as the REST
///    thread's message entries
///
/// Messages are *persisted over REST*; this socket only carries the fan-out,
/// so a failed connection degrades the screen to send-and-see rather than
/// breaking it.
class ChatSocket {
  ChatSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  String? _joinedOrderId;

  final _messages = StreamController<ChatMessageModel>.broadcast();
  final _connected = StreamController<bool>.broadcast();

  /// Live messages for the joined order.
  Stream<ChatMessageModel> get messages => _messages.stream;

  /// Connection state, so the UI can say when realtime is unavailable.
  Stream<bool> get connectionChanges => _connected.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Connects (if needed) and joins [orderId]'s room. Safe to call repeatedly.
  Future<void> join(String orderId) async {
    final token = await _tokenStorage.accessToken;
    if (token == null) return;

    if (_socket == null) {
      _socket = io.io(
        '${ApiConfig.baseUrl}/chat',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            // Reconnect is handled by the client; each reconnect re-joins the
            // room below, because room membership dies with the socket.
            .enableReconnection()
            .enableForceNew()
            .build(),
      );

      _socket!
        ..onConnect((_) {
          _connected.add(true);
          final joined = _joinedOrderId;
          if (joined != null) _socket!.emit('order:join', joined);
        })
        ..onDisconnect((_) => _connected.add(false))
        // A refused join leaves the socket up but delivers nothing, so report
        // it as "not connected" — the screen then says realtime is unavailable
        // instead of waiting for messages that will never arrive.
        ..on('order:join:denied', (_) => _connected.add(false))
        ..on('order:joined', (_) => _connected.add(true))
        ..on('message', (data) {
          if (data is Map) {
            _messages.add(
              ChatMessageModel.fromJson(Map<String, dynamic>.from(data)),
            );
          }
        });
    }

    if (_joinedOrderId != null && _joinedOrderId != orderId) {
      _socket!.emit('order:leave', _joinedOrderId);
    }
    _joinedOrderId = orderId;
    if (_socket!.connected) _socket!.emit('order:join', orderId);
  }

  Future<void> dispose() async {
    final joined = _joinedOrderId;
    if (joined != null && (_socket?.connected ?? false)) {
      _socket!.emit('order:leave', joined);
    }
    _socket?.dispose();
    _socket = null;
    _joinedOrderId = null;
    await _messages.close();
    await _connected.close();
  }
}
