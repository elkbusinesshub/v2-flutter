import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/language_model.dart';

/// Supported app languages and the user's language preference.
///
/// Backend contract:
///  * `GET   /config/languages` → `[{ code, flag, name, nativeName }]`
///  * `PATCH /users/me/language { language }` → updated ProfileDto
class LanguageRepository {
  LanguageRepository(this._client);

  final ApiClient _client;

  Future<List<LanguageModel>> getLanguages() async {
    final data = await _client.get(ApiEndpoints.languages) as List;
    return data
        .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> selectLanguage(String code) {
    return _client.patch(ApiEndpoints.profileLanguage, data: {'language': code});
  }
}
