import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for app-level flags.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_complete';
  static const _authKey = 'is_authenticated';
  static const _guestKey = 'is_guest';
  static const _languageKey = 'selected_language';
  static const _userNameKey = 'user_name';
  static const _userPhoneKey = 'user_phone';

  bool get hasCompletedOnboarding => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingComplete() => _prefs.setBool(_onboardingKey, true);

  bool get isAuthenticated => _prefs.getBool(_authKey) ?? false;
  Future<void> setAuthenticated(bool value) => _prefs.setBool(_authKey, value);

  /// Local-only guest mode: the user browses without a backend session.
  bool get isGuest => _prefs.getBool(_guestKey) ?? false;
  Future<void> setGuest(bool value) => _prefs.setBool(_guestKey, value);

  String get selectedLanguage => _prefs.getString(_languageKey) ?? 'en';
  Future<void> setSelectedLanguage(String code) =>
      _prefs.setString(_languageKey, code);

  String? get userName => _prefs.getString(_userNameKey);
  Future<void> setUserName(String name) => _prefs.setString(_userNameKey, name);

  /// Cached so a checkout can put a contact number on an order without
  /// stopping to ask for one the account already has.
  String? get userPhone => _prefs.getString(_userPhoneKey);
  Future<void> setUserPhone(String phone) => _prefs.setString(_userPhoneKey, phone);
}
