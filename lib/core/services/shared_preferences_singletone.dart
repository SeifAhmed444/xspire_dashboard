import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _preferences;

  // ValueNotifier for notification count
  static final ValueNotifier<int> notificationNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> notificationNotifier2 = ValueNotifier<bool>(
    false,
  );
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    // // Initialize notifier with saved value
    // notificationNotifier.value = _preferences.getInt(Knotification) ?? 0;
  }

  static Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static bool getBool(String key) {
    return _preferences.getBool(key) ?? false;
  }
}
