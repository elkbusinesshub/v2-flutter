import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Thin wrapper around [Dio] that all repositories depend on.
///
/// For now every call resolves against the fixtures in `dummy_data.dart`
/// via [simulate], so the app runs fully offline. [dio] is still configured
/// with the real `baseUrl` so that switching a repository over to a live
/// endpoint only means replacing `apiClient.simulate(...)` with
/// `apiClient.dio.get(...)`.
class ApiClient {
  ApiClient({Dio? dio, this.baseUrl = 'https://api.elkbusinesshub.com/v1'})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio dio;
  final String baseUrl;

  /// Simulates a network round-trip for [endpoint] and returns [response].
  ///
  /// Adds a small artificial delay so loading states are visible, and logs
  /// the call to make it obvious which "endpoint" a screen depends on.
  Future<T> simulate<T>(
    String endpoint,
    T Function() response, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    developer.log('GET $endpoint', name: 'ApiClient');
    await Future.delayed(delay);
    return response();
  }

  /// Simulates a mutation (POST/PUT/PATCH) against [endpoint].
  Future<T> simulateMutation<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function() response, {
    Duration delay = const Duration(milliseconds: 600),
  }) async {
    developer.log('POST $endpoint body=$body', name: 'ApiClient');
    await Future.delayed(delay);
    return response();
  }
}
