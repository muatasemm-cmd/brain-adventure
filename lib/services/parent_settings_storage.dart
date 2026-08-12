import 'package:shared_preferences/shared_preferences.dart';

class ParentSettingsStorage {
  static const _pinKey = 'parent_pin_v1';
  static const _surpriseHourKey = 'daily_surprise_hour_v1';
  static const _breakMinutesKey = 'healthy_break_minutes_v1';
  static const _dailyLimitMinutesKey = 'daily_limit_minutes_v1';

  static Future<String?> loadPin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pinKey);
  }

  static Future<void> savePin(String pin) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pinKey, pin);
  }

  static Future<int> loadSurpriseHour() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_surpriseHourKey) ?? 20;
  }

  static Future<void> saveSurpriseHour(int hour) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_surpriseHourKey, hour.clamp(0, 23));
  }

  static Future<int> loadBreakMinutes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_breakMinutesKey) ?? 20;
  }

  static Future<void> saveBreakMinutes(int minutes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_breakMinutesKey, minutes);
  }

  static Future<int> loadDailyLimitMinutes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_dailyLimitMinutesKey) ?? 60;
  }

  static Future<void> saveDailyLimitMinutes(int minutes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_dailyLimitMinutesKey, minutes);
  }
}
