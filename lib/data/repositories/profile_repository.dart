import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/user_model.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<UserModel> getProfile() {
    return _client.simulate(
      '/users/me',
      () => UserModel.fromJson(dummyUserJson),
    );
  }

  Future<void> signOut() {
    return _client.simulateMutation('/auth/sign-out', {}, () {});
  }
}
