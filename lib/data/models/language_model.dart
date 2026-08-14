/// A supported app language (backend `GET /config/languages`).
class LanguageModel {
  const LanguageModel({
    required this.code,
    required this.flag,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String flag;
  final String name;
  final String nativeName;

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        code: json['code'] as String,
        flag: json['flag'] as String,
        name: json['name'] as String,
        nativeName: json['nativeName'] as String,
      );
}
