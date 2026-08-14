import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/token_storage.dart';
import '../../core/errors/api_exception.dart';
import '../models/user_model.dart';

/// Phone/OTP authentication against the ELK backend, plus local guest mode.
///
/// Backend contract:
///  * `POST /auth/otp/request { phone }` → `{ resendInSeconds }`
///  * `POST /auth/otp/verify { phone, otp }` → token pair
///  * `POST /auth/logout { refreshToken }` → revokes the session
///  * `GET  /users/me` → the user's profile
class AuthRepository {
  AuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  /// Requests an OTP for [phoneNumber] (E.164). Returns the resend countdown
  /// in seconds. In development the code is printed in the backend logs.
  Future<int> requestOtp(String phoneNumber) async {
    final data = await _client.post(
      ApiEndpoints.requestOtp,
      data: {'phone': phoneNumber},
    );
    return (data as Map<String, dynamic>)['resendInSeconds'] as int;
  }

  /// Verifies [otp] for [phoneNumber], stores the issued token pair, and
  /// returns the authenticated user's profile.
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final pair = await _client.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phoneNumber, 'otp': otp},
    ) as Map<String, dynamic>;

    await _tokenStorage.saveTokens(
      accessToken: pair['accessToken'] as String,
      refreshToken: pair['refreshToken'] as String,
    );

    return getProfile();
  }

  /// Fetches the current user's profile. Requires a valid session.
  Future<UserModel> getProfile() async {
    final data = await _client.get(ApiEndpoints.profile);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Whether a token pair is stored on this device.
  Future<bool> get hasSession => _tokenStorage.hasTokens;

  /// Validates the stored session against the backend.
  ///
  /// Returns the user when the session is (still) valid, `null` when there is
  /// no session or the backend rejected it (tokens are cleared). Network-level
  /// failures are rethrown so the caller can decide whether to trust the
  /// stored session while offline.
  Future<UserModel?> restoreSession() async {
    if (!await hasSession) return null;
    try {
      return await getProfile();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _tokenStorage.clear();
        return null;
      }
      rethrow;
    }
  }

  /// Revokes the session server-side and always clears local tokens.
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken != null) {
        await _client.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } on ApiException {
      // Local sign-out must succeed even if the server call fails
      // (offline, already-revoked session, ...).
    } finally {
      await _tokenStorage.clear();
    }
  }

  /// Continues as a guest without creating an account — no backend session.
  UserModel continueAsGuest() {
    return const UserModel(id: 'guest', name: 'Guest User', phone: '');
  }
}
