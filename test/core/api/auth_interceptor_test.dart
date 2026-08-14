import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:elk/core/api/interceptors/auth_interceptor.dart';
import 'package:elk/core/api/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the Keystore-backed real thing.
class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage({this.access, this.refresh});

  String? access;
  String? refresh;
  int clearCount = 0;

  @override
  Future<String?> get accessToken async => access;

  @override
  Future<String?> get refreshToken async => refresh;

  @override
  Future<bool> get hasTokens async => refresh != null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clearCount++;
  }
}

/// Scripts HTTP responses per path, and records what was actually sent so the
/// tests can assert on the Authorization header the interceptor attached.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> sent = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int status) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late _FakeTokenStorage storage;
  late Dio dio;
  late Dio refreshDio;
  late _ScriptedAdapter apiAdapter;
  late _ScriptedAdapter refreshAdapter;
  late int sessionExpiredCount;

  /// Wires an interceptor over two scripted transports: one for the API call,
  /// one for the bare refresh client.
  void build({
    required ResponseBody Function(RequestOptions) api,
    required ResponseBody Function(RequestOptions) refresh,
  }) {
    apiAdapter = _ScriptedAdapter(api);
    refreshAdapter = _ScriptedAdapter(refresh);

    dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1'))
      ..httpClientAdapter = apiAdapter;
    refreshDio = Dio(BaseOptions(baseUrl: 'http://test.local/api/v1'))
      ..httpClientAdapter = refreshAdapter;

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        dio: dio,
        refreshDio: refreshDio,
        onSessionExpired: () => sessionExpiredCount++,
      ),
    );
  }

  setUp(() {
    storage = _FakeTokenStorage(access: 'access-1', refresh: 'refresh-1');
    sessionExpiredCount = 0;
  });

  group('request signing', () {
    test('attaches the stored access token as a Bearer header', () async {
      build(
        api: (_) => _json({'data': 'ok'}, 200),
        refresh: (_) => _json({}, 200),
      );

      await dio.get<dynamic>('/wallet');

      expect(apiAdapter.sent.single.headers['Authorization'], 'Bearer access-1');
    });

    test('sends no Authorization header when signed out', () async {
      // Guest mode browses public endpoints — an empty Bearer would be worse
      // than none at all.
      storage.access = null;
      build(
        api: (_) => _json({'data': 'ok'}, 200),
        refresh: (_) => _json({}, 200),
      );

      await dio.get<dynamic>('/home/feed');

      expect(apiAdapter.sent.single.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('401 handling', () {
    test('rotates the pair and replays the request with the new token',
        () async {
      var apiCalls = 0;
      build(
        api: (_) {
          apiCalls++;
          // Expired on the first attempt, fine once refreshed.
          return apiCalls == 1
              ? _json({'message': 'Unauthorized'}, 401)
              : _json({'data': 'wallet'}, 200);
        },
        refresh: (_) => _json({
          'data': {'accessToken': 'access-2', 'refreshToken': 'refresh-2'},
        }, 200),
      );

      final response = await dio.get<dynamic>('/wallet');

      expect(response.statusCode, 200);
      expect((response.data as Map)['data'], 'wallet');
      // The rotated pair is persisted, not just used once.
      expect(storage.access, 'access-2');
      expect(storage.refresh, 'refresh-2');
      // The replay carries the new token, not the stale one.
      expect(apiAdapter.sent.last.headers['Authorization'], 'Bearer access-2');
      expect(refreshAdapter.sent.single.path, '/auth/refresh');
      expect(sessionExpiredCount, 0);
    });

    test('does not refresh when the 401 came from /auth/ itself', () async {
      // A 401 from /auth/otp/verify means the OTP was wrong. Refreshing there
      // would mask a credential error as a session problem.
      build(
        api: (_) => _json({'message': 'Invalid OTP'}, 401),
        refresh: (_) => _json({}, 200),
      );

      await expectLater(
        dio.post<dynamic>('/auth/otp/verify', data: {'otp': '000000'}),
        throwsA(isA<DioException>()),
      );

      expect(refreshAdapter.sent, isEmpty);
      expect(storage.clearCount, 0);
      expect(sessionExpiredCount, 0);
    });

    test('ends the session when the refresh token is itself rejected',
        () async {
      build(
        api: (_) => _json({'message': 'Unauthorized'}, 401),
        refresh: (_) => _json({'message': 'Refresh token revoked'}, 401),
      );

      await expectLater(
        dio.get<dynamic>('/wallet'),
        throwsA(isA<DioException>()),
      );

      expect(storage.clearCount, 1);
      expect(storage.refresh, isNull);
      expect(sessionExpiredCount, 1);
    });

    test('ends the session when there is no refresh token to use', () async {
      storage.refresh = null;
      build(
        api: (_) => _json({'message': 'Unauthorized'}, 401),
        refresh: (_) => _json({}, 200),
      );

      await expectLater(
        dio.get<dynamic>('/wallet'),
        throwsA(isA<DioException>()),
      );

      // Nothing to refresh with, so the network is never touched.
      expect(refreshAdapter.sent, isEmpty);
      expect(sessionExpiredCount, 1);
    });

    test('leaves non-401 failures alone', () async {
      build(
        api: (_) => _json({'message': 'Server error'}, 500),
        refresh: (_) => _json({}, 200),
      );

      await expectLater(
        dio.get<dynamic>('/wallet'),
        throwsA(isA<DioException>()),
      );

      expect(refreshAdapter.sent, isEmpty);
      expect(sessionExpiredCount, 0);
    });

    test('refreshes once for concurrent 401s and retries the rest', () async {
      // The reason AuthInterceptor extends QueuedInterceptor: three screens
      // loading at once must not fire three rotations, which would invalidate
      // each other on a backend that rotates refresh tokens.
      final expired = <String>{'/wallet', '/offers', '/notifications'};
      build(
        api: (options) {
          if (expired.remove(options.path)) {
            return _json({'message': 'Unauthorized'}, 401);
          }
          return _json({'data': 'ok'}, 200);
        },
        refresh: (_) => _json({
          'data': {'accessToken': 'access-2', 'refreshToken': 'refresh-2'},
        }, 200),
      );

      final responses = await Future.wait([
        dio.get<dynamic>('/wallet'),
        dio.get<dynamic>('/offers'),
        dio.get<dynamic>('/notifications'),
      ]);

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(refreshAdapter.sent, hasLength(1));
      expect(storage.access, 'access-2');
    });
  });
}
