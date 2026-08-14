import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

/// The current user's profile against the ELK backend.
///
/// Backend contract:
///  * `GET   /users/me` → ProfileDto
///  * `PATCH /users/me { name?, email? }` → updated ProfileDto
class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<UserModel> getProfile() async {
    final data = await _client.get(ApiEndpoints.profile);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Updates the given fields only; omitted fields are left untouched.
  Future<UserModel> updateProfile({String? name, String? email}) async {
    final data = await _client.patch(ApiEndpoints.profile, data: {
      'name': ?name,
      'email': ?email,
    });
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
