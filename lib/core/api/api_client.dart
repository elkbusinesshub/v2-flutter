import 'dart:typed_data';

import 'dart:ui';

import 'package:dio/dio.dart';

import '../errors/api_exception.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'token_storage.dart';

/// The live HTTP client every integrated repository depends on.
///
/// Responsibilities:
///  * Dio configuration (base URL, timeouts, interceptors).
///  * Unwrapping the backend envelope `{ success, message, data, meta? }`
///    so repositories work directly with `data`.
///  * Normalizing every failure into an [ApiException].
///
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    VoidCallback? onSessionExpired,
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.apiBaseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                sendTimeout: ApiConfig.sendTimeout,
                headers: {'Accept': 'application/json'},
              ),
            ) {
    this.dio.interceptors.addAll([
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: this.dio,
        onSessionExpired: onSessionExpired,
      ),
      LoggingInterceptor(),
    ]);
  }

  final Dio dio;

  /// GET [path] and return the envelope's `data` field.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _request(() => dio.get<dynamic>(path, queryParameters: queryParameters));
  }

  /// GET [path] as raw bytes.
  ///
  /// Bypasses the envelope unwrapping in [_request]: this endpoint answers with
  /// an image, not `{ success, message, data }`.
  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) {
    return _request(() => dio.post<dynamic>(path, data: data));
  }

  /// POSTs `multipart/form-data`. Dio sets the boundary itself, so [data] is
  /// passed through untouched rather than JSON-encoded like [post].
  Future<dynamic> postMultipart(String path, FormData data) {
    return _request(() => dio.post<dynamic>(path, data: data));
  }

  Future<dynamic> patch(String path, {Object? data}) {
    return _request(() => dio.patch<dynamic>(path, data: data));
  }

  Future<dynamic> delete(String path, {Object? data}) {
    return _request(() => dio.delete<dynamic>(path, data: data));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      final body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
