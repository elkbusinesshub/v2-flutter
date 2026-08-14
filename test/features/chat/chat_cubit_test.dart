import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/api/chat_socket.dart';
import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/chat_models.dart';
import 'package:elk/data/repositories/chat_repository.dart';
import 'package:elk/features/chat/cubit/chat_cubit.dart';

ChatMessageModel _message(String id, String text, {bool outgoing = true}) =>
    ChatMessageModel(
      id: id,
      text: text,
      time: '9:16 AM',
      isOutgoing: outgoing,
      senderInitials: outgoing ? null : 'RS',
    );

const _thread = ChatThreadModel(
  contactName: 'Royal Shine Cleaning Co.',
  contactInitials: 'RS',
  contactStatus: '● Online · Service Provider',
  dateLabel: 'Today, 9:15 AM',
  messages: [],
);

class _FakeChatRepository implements ChatRepository {
  Object? loadError;
  Object? sendError;
  String? lastSentText;
  int nextId = 1;

  @override
  Future<ChatThreadModel> getChatThread(String orderId) async {
    if (loadError != null) throw loadError!;
    return _thread;
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String orderId,
    required String text,
  }) async {
    lastSentText = text;
    if (sendError != null) throw sendError!;
    return _message('m${nextId++}', text);
  }
}

/// Stands in for the real Socket.IO transport — the cubit only depends on the
/// two streams and `join`/`dispose`.
class _FakeChatSocket implements ChatSocket {
  final _messages = StreamController<ChatMessageModel>.broadcast();
  final _connected = StreamController<bool>.broadcast();
  final List<String> joined = [];
  Object? joinError;
  bool disposed = false;

  @override
  Stream<ChatMessageModel> get messages => _messages.stream;

  @override
  Stream<bool> get connectionChanges => _connected.stream;

  @override
  bool get isConnected => true;

  @override
  Future<void> join(String orderId) async {
    if (joinError != null) throw joinError!;
    joined.add(orderId);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _messages.close();
    await _connected.close();
  }

  void emitMessage(ChatMessageModel m) => _messages.add(m);
  void emitConnected(bool value) => _connected.add(value);
}

void main() {
  late _FakeChatRepository repository;
  late _FakeChatSocket socket;

  Future<ChatCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return ChatCubit(repository, socket, preferences);
  }

  setUp(() {
    repository = _FakeChatRepository();
    socket = _FakeChatSocket();
  });

  test('loads the thread and joins the order room', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    expect(cubit.state.status, ChatStatus.loaded);
    expect(cubit.state.thread!.contactName, 'Royal Shine Cleaning Co.');
    expect(socket.joined, ['b1']);
  });

  test('guest mode short-circuits and never opens a socket', () async {
    repository.loadError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadThread('b1');

    expect(cubit.state.status, ChatStatus.guest);
    expect(socket.joined, isEmpty);
  });

  test('a provider message arriving over the socket is appended', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    socket.emitMessage(_message('p1', 'On my way!', outgoing: false));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.thread!.messages.single.text, 'On my way!');
    expect(cubit.state.thread!.messages.single.isOutgoing, isFalse);
  });

  test('the sender\'s own socket echo is not duplicated', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    await cubit.sendMessage('b1', 'Hello');
    expect(cubit.state.thread!.messages, hasLength(1));

    // The server broadcasts to the whole room, sender included.
    socket.emitMessage(_message('m1', 'Hello'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.thread!.messages, hasLength(1));
  });

  test('a socket echo that lands before the POST response is not duplicated',
      () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    // Simulate the broadcast overtaking the HTTP response.
    socket.emitMessage(_message('m1', 'Hello'));
    await Future<void>.delayed(Duration.zero);
    await cubit.sendMessage('b1', 'Hello');

    expect(cubit.state.thread!.messages, hasLength(1));
  });

  test('sending trims the text and ignores an empty message', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    await cubit.sendMessage('b1', '   ');
    expect(repository.lastSentText, isNull);

    await cubit.sendMessage('b1', '  Hi there  ');
    expect(repository.lastSentText, 'Hi there');
  });

  test('a failed send returns the message and appends nothing', () async {
    repository.sendError =
        const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    final error = await cubit.sendMessage('b1', 'Hello');
    expect(error, contains('internet'));
    expect(cubit.state.thread!.messages, isEmpty);
    expect(cubit.state.isSending, isFalse);
  });

  test('connection changes are reflected in the state', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    socket.emitConnected(true);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isRealtimeConnected, isTrue);

    socket.emitConnected(false);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isRealtimeConnected, isFalse);
  });

  test('a socket that cannot connect still leaves a usable thread', () async {
    socket.joinError = StateError('no route to host');
    final cubit = await buildCubit();
    await cubit.loadThread('b1');

    // The thread loaded over HTTP; only realtime is degraded.
    expect(cubit.state.status, ChatStatus.loaded);
    expect(cubit.state.isRealtimeConnected, isFalse);

    await cubit.sendMessage('b1', 'Still works');
    expect(cubit.state.thread!.messages.single.text, 'Still works');
  });

  test('closing the cubit disposes the socket', () async {
    final cubit = await buildCubit();
    await cubit.loadThread('b1');
    await cubit.close();

    expect(socket.disposed, isTrue);
  });

  test('surfaces a friendly error when the thread fails to load', () async {
    repository.loadError =
        const ApiException(ApiErrorType.notFound, 'Order not found');
    final cubit = await buildCubit();
    await cubit.loadThread('nope');

    expect(cubit.state.status, ChatStatus.error);
    expect(cubit.state.errorMessage, 'Order not found');
  });
}
