import 'dart:ui';

import 'package:dio/dio.dart';

import '../api_config.dart';
import '../api_endpoints.dart';
import '../token_storage.dart';

/// Attaches the Bearer token to every request and transparently rotates the
/// token pair on 401 responses.
///
/// Extends [QueuedInterceptor] so concurrent 401s are handled one at a time.
/// Serialising alone does not deduplicate them, so [onError] also checks
/// whether the stored token has already moved past the one the failed request
/// carried: the first failure refreshes, the rest simply retry with the new
/// token.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    this.onSessionExpired,
    Dio? refreshDio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio,
        _refreshDio = refreshDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.apiBaseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
              ),
            );

  final TokenStorage _tokenStorage;

  /// The main client, used to replay the failed request after a refresh.
  final Dio _dio;

  /// Invoked once when the refresh token itself is rejected — the app should
  /// treat the session as ended (clear local auth state, go to login).
  final VoidCallback? onSessionExpired;

  /// Bare client for the refresh call so it never recurses into this
  /// interceptor. Injectable so tests can script the refresh response.
  final Dio _refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    // Never try to refresh for the auth endpoints themselves: a 401 from
    // /auth/* means the credentials in the request body were wrong, not that
    // the access token is stale.
    final isAuthPath = err.requestOptions.path.startsWith('/auth/');

    if (status != 401 || isAuthPath) {
      handler.next(err);
      return;
    }

    // QueuedInterceptor serialises these handlers but does not deduplicate
    // them: without this check, six screens loading against one expired token
    // would rotate six times and trip the backend's 10/min refresh throttle —
    // and a throttled refresh reads as a dead session and signs the user out.
    // A token that has already moved on means an earlier 401 in this queue
    // refreshed; replay against it instead of rotating again.
    final current = await _tokenStorage.accessToken;
    if (current != null &&
        err.requestOptions.headers['Authorization'] != 'Bearer $current') {
      await _replay(err, current, handler);
      return;
    }

    final refreshed = await _tryRefresh();
    if (!refreshed) {
      await _tokenStorage.clear();
      onSessionExpired?.call();
      handler.next(err);
      return;
    }

    final token = await _tokenStorage.accessToken;
    if (token == null) {
      handler.next(err);
      return;
    }
    await _replay(err, token, handler);
  }

  /// Re-sends the failed request signed with [token].
  Future<void> _replay(
    DioException err,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final pair = response.data?['data'] as Map<String, dynamic>?;
      if (pair == null) return false;
      await _tokenStorage.saveTokens(
        accessToken: pair['accessToken'] as String,
        refreshToken: pair['refreshToken'] as String,
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
