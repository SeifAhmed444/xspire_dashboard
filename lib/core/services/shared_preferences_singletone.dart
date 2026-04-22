import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _preferences;

  static final ValueNotifier<int> notificationNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> notificationNotifier2 =
      ValueNotifier<bool>(false);

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static bool getBool(String key) {
    return _preferences.getBool(key) ?? false;
  }

  // ── Email persistence ───────────────────────────────────────────────────────
  // Saves the logged-in user's email so it can be restored after a cold start.
  static const _kSavedEmail = 'saved_email';

  static Future<void> saveEmail(String email) async {
    await _preferences.setString(_kSavedEmail, email);
  }

  static String? getSavedEmail() {
    return _preferences.getString(_kSavedEmail);
  }

  static Future<void> clearEmail() async {
    await _preferences.remove(_kSavedEmail);
  }
}