import 'package:shared_preferences/shared_preferences.dart';

class PlayTimeService {
  static String _key(String playerId, DateTime now) =>
      'daily_play_${playerId}_${now.year}_${now.month}_${now.day}';

  static Future<int> loadTodaySeconds(String playerId, DateTime now) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_key(playerId, now)) ?? 0;
  }

  static Future<void> addSession(
    String playerId,
    DateTime now,
    int seconds,
  ) async {
    if (seconds <= 0) return;
    final preferences = await SharedPreferences.getInstance();
    final key = _key(playerId, now);
    await preferences.setInt(key, (preferences.getInt(key) ?? 0) + seconds);
  }
}
