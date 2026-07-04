import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/user_model.dart';

/// Handles phone/OTP authentication and social/guest sign-in.
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// Requests an OTP for [phoneNumber]. Returns the resend countdown in seconds.
  Future<int> requestOtp(String phoneNumber) {
    return _client.simulateMutation(
      '/auth/otp/request',
      {'phone': phoneNumber},
      () => 30,
    );
  }

  /// Verifies [otp] for [phoneNumber] and returns the authenticated user.
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) {
    return _client.simulateMutation(
      '/auth/otp/verify',
      {'phone': phoneNumber, 'otp': otp},
      () => UserModel.fromJson(dummyUserJson),
    );
  }

  /// Signs the user in via Google OAuth.
  Future<UserModel> signInWithGoogle() {
    return _client.simulateMutation(
      '/auth/google',
      {},
      () => UserModel.fromJson(dummyUserJson),
    );
  }

  /// Continues as a guest without creating an account.
  Future<UserModel> continueAsGuest() {
    return _client.simulate(
      '/auth/guest',
      () => UserModel.fromJson({
        ...dummyUserJson,
        'id': 'guest',
        'name': 'Guest User',
        'bookingsCount': 0,
        'rewardPoints': 0,
      }),
    );
  }
}
