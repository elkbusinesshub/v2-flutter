import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request/response/error lines to the developer console in debug
/// builds only. Bodies are logged for errors, not successes, to keep the
/// console readable.
class LoggingInterceptor extends Interceptor {
  static const _name = 'ApiClient';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log('→ ${options.method} ${options.uri}', name: _name);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
        name: _name,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '✕ ${err.response?.statusCode ?? err.type.name} '
        '${err.requestOptions.method} ${err.requestOptions.uri} '
        '${err.response?.data ?? err.message}',
        name: _name,
      );
    }
    handler.next(err);
  }
}
