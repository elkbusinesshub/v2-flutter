import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elk/core/errors/api_exception.dart';

void main() {
  final requestOptions = RequestOptions(path: '/auth/otp/request');

  DioException badResponse(int status, Object body) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: status,
        data: body,
      ),
    );
  }

  group('ApiException.fromDioException', () {
    test('maps timeouts to a friendly timeout error', () {
      final e = ApiException.fromDioException(DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      ));
      expect(e.type, ApiErrorType.timeout);
      expect(e.message, contains('timed out'));
    });

    test('maps connection errors to a network error', () {
      final e = ApiException.fromDioException(DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      ));
      expect(e.type, ApiErrorType.network);
      expect(e.message, contains('internet'));
    });

    test('uses the backend message and code for 400s', () {
      final e = ApiException.fromDioException(badResponse(400, {
        'success': false,
        'message': 'phone must be in E.164 format, e.g. +14155552671',
        'error': 'VALIDATION_FAILED',
      }));
      expect(e.type, ApiErrorType.validation);
      expect(e.message, contains('E.164'));
      expect(e.code, 'VALIDATION_FAILED');
      expect(e.statusCode, 400);
    });

    test('prefers per-field messages from the details array', () {
      final e = ApiException.fromDioException(badResponse(400, {
        'success': false,
        'message': 'Validation failed',
        'error': 'VALIDATION_ERROR',
        'details': [
          {'field': 'phone', 'message': 'phone must be in E.164 format, e.g. +14155552671'},
        ],
      }));
      expect(e.message, 'phone must be in E.164 format, e.g. +14155552671');
    });

    test('joins class-validator message lists', () {
      final e = ApiException.fromDioException(badResponse(400, {
        'message': ['otp must be a 4-digit code', 'phone must not be empty'],
      }));
      expect(e.message, 'otp must be a 4-digit code\nphone must not be empty');
    });

    test('maps 401 to unauthorized', () {
      final e = ApiException.fromDioException(
        badResponse(401, {'message': 'Invalid or expired OTP'}),
      );
      expect(e.type, ApiErrorType.unauthorized);
      expect(e.isUnauthorized, isTrue);
      expect(e.message, 'Invalid or expired OTP');
    });

    test('maps 429 to tooManyRequests', () {
      final e = ApiException.fromDioException(
        badResponse(429, {'message': 'ThrottlerException: Too Many Requests'}),
      );
      expect(e.type, ApiErrorType.tooManyRequests);
    });

    test('hides opaque 5xx messages behind a friendly fallback', () {
      final e = ApiException.fromDioException(
        badResponse(500, {'message': 'Internal server error'}),
      );
      expect(e.type, ApiErrorType.server);
      expect(e.message, isNot(contains('Internal server error')));
    });
  });
}
