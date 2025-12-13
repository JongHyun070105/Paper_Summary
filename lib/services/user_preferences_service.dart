import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _interestsKey = 'user_interests';
  static const String _languageKey = 'app_language';
  static const String _notificationsKey = 'notifications_enabled';

  // 관심사 저장/불러오기
  Future<List<String>> getInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_interestsKey) ?? [];
  }

  Future<void> saveInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_interestsKey, interests);
  }

  // 언어 설정
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ko';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // 알림 설정
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
}
