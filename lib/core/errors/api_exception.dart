import 'dart:io';

import 'package:dio/dio.dart';

import '../l10n/l10n.dart';

/// Broad failure categories the UI can branch on.
enum ApiErrorType {
  /// Device offline or host unreachable.
  network,

  /// Connect/send/receive timeout.
  timeout,

  /// 401 — missing/expired credentials (after a failed token refresh).
  unauthorized,

  /// 403 — authenticated but not allowed.
  forbidden,

  /// 404 — resource does not exist.
  notFound,

  /// 400/422 — the backend rejected the request payload.
  validation,

  /// 429 — throttled (OTP endpoints are rate limited).
  tooManyRequests,

  /// 5xx — backend failure.
  server,

  /// Request was cancelled by the caller.
  cancelled,

  unknown,
}

/// The single error type repositories throw.
///
/// [message] is always safe to show to the user: it is either the backend's
/// own message (`{ success: false, message, error, details? }`) or a
/// friendly fallback for transport-level failures.
class ApiException implements Exception {
  const ApiException(
    this.type,
    this.message, {
    this.statusCode,
    this.code,
    this.details,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  /// Machine-readable backend error code (e.g. `OTP_INVALID`), when present.
  final String? code;

  /// Extra error payload from the backend (e.g. per-field validation issues).
  final Object? details;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;
  bool get isNetwork => type == ApiErrorType.network;

  factory ApiException.fromDioException(DioException exception) {
    final l10n = L10n.current;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(ApiErrorType.timeout, l10n.errorTimeout);
      case DioExceptionType.connectionError:
        return ApiException(ApiErrorType.network, l10n.errorNoInternet);
      case DioExceptionType.cancel:
        return ApiException(ApiErrorType.cancelled, l10n.errorCancelled);
      case DioExceptionType.badResponse:
        return ApiException.fromResponse(exception.response!);
      case DioExceptionType.badCertificate:
        return ApiException(ApiErrorType.network, l10n.errorInsecureConnection);
      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return ApiException(ApiErrorType.network, l10n.errorNoInternet);
        }
        return ApiException(ApiErrorType.unknown, l10n.errorUnknown);
    }
  }

  factory ApiException.fromResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;

    String? backendMessage;
    String? backendCode;
    Object? backendDetails;
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      // class-validator errors arrive as a list of strings.
      if (message is List) {
        backendMessage = message.join('\n');
      } else if (message is String && message.isNotEmpty) {
        backendMessage = message;
      }
      backendCode = body['error'] as String?;
      backendDetails = body['details'];

      // Validation failures carry the useful text in
      // details: [{ field, message }] while message is just "Validation
      // failed" — prefer the per-field messages.
      final details = backendDetails;
      if (details is List) {
        final fieldMessages = details
            .whereType<Map>()
            .map((d) => d['message'])
            .whereType<String>()
            .toList();
        if (fieldMessages.isNotEmpty) {
          backendMessage = fieldMessages.join('\n');
        }
      }
    }

    final l10n = L10n.current;
    final (type, fallback) = switch (status) {
      400 || 422 => (ApiErrorType.validation, l10n.errorValidation),
      401 => (ApiErrorType.unauthorized, l10n.errorSessionExpired),
      403 => (ApiErrorType.forbidden, l10n.errorForbidden),
      404 => (ApiErrorType.notFound, l10n.errorNotFound),
      429 => (ApiErrorType.tooManyRequests, l10n.errorTooManyRequests),
      >= 500 => (ApiErrorType.server, l10n.errorServer),
      _ => (ApiErrorType.unknown, l10n.errorUnknown),
    };

    // 5xx backend messages are opaque ("Internal server error") — prefer the
    // friendly fallback there; everywhere else the backend message is written
    // for end users.
    final message = (type == ApiErrorType.server ? null : backendMessage) ?? fallback;

    return ApiException(
      type,
      message,
      statusCode: status,
      code: backendCode,
      details: backendDetails,
    );
  }

  @override
  String toString() => message;
}

/// The message blocs/cubits surface for any caught error: the [ApiException]
/// message when there is one, a generic fallback otherwise.
String friendlyErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  return L10n.current.errorUnknown;
}
