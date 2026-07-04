import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/language_model.dart';

class LanguageRepository {
  LanguageRepository(this._client);

  final ApiClient _client;

  Future<List<LanguageModel>> getLanguages() {
    return _client.simulate(
      '/config/languages',
      () => dummyLanguagesJson
          .map((e) => LanguageModel(
                code: e['code']!,
                flag: e['flag']!,
                name: e['name']!,
                nativeName: e['nativeName']!,
              ))
          .toList(),
    );
  }

  Future<void> selectLanguage(String code) {
    return _client.simulateMutation(
      '/users/me/language',
      {'language': code},
      () {},
    );
  }
}
