import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adult_player.dart';

class AdultStorage {
  static const _playersKey = 'adult_players_v1';

  static Future<List<AdultPlayer>> loadPlayers() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_playersKey);
    if (encoded == null) return const [];
    return (jsonDecode(encoded) as List)
        .map((item) => AdultPlayer.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<List<AdultPlayer>> addPlayer({
    required String name,
    required String ageGroup,
    required String level,
  }) async {
    final players = (await loadPlayers()).toList()
      ..add(
        AdultPlayer(
          id: 'adult_${DateTime.now().microsecondsSinceEpoch}',
          name: name.trim(),
          ageGroup: ageGroup,
          level: level,
        ),
      );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _playersKey,
      jsonEncode(players.map((player) => player.toJson()).toList()),
    );
    return players;
  }

  static Future<List<AdultPlayer>> deletePlayer(String id) async {
    final players = (await loadPlayers())
        .where((item) => item.id != id)
        .toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _playersKey,
      jsonEncode(players.map((player) => player.toJson()).toList()),
    );
    return players;
  }

  static String _progressKey(String playerId) => 'adult_progress_$playerId';
  static String _mistakesKey(String playerId) => 'adult_mistakes_$playerId';
  static String _dailyKey(String playerId) => 'adult_daily_$playerId';

  static Future<Map<String, int>> loadProgress(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_progressKey(playerId));
    if (encoded == null) return {};
    return (jsonDecode(encoded) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value as int),
    );
  }

  static Future<void> completeLevel({
    required String playerId,
    required String categoryId,
    required int level,
    required int score,
  }) async {
    final progress = await loadProgress(playerId);
    final key = '$categoryId:$level';
    if (score > (progress[key] ?? -1)) progress[key] = score;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_progressKey(playerId), jsonEncode(progress));
  }

  static Future<Set<String>> loadMistakes(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_mistakesKey(playerId)) ?? const [])
        .toSet();
  }

  static Future<void> recordMistake(String playerId, String questionId) async {
    final mistakes = await loadMistakes(playerId)
      ..add(questionId);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_mistakesKey(playerId), mistakes.toList());
  }

  static Future<void> masterQuestion(String playerId, String questionId) async {
    final mistakes = await loadMistakes(playerId)
      ..remove(questionId);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_mistakesKey(playerId), mistakes.toList());
  }

  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Future<Map<String, dynamic>> loadDaily(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_dailyKey(playerId));
    if (encoded == null) return {};
    return jsonDecode(encoded) as Map<String, dynamic>;
  }

  static Future<int> recordDailyResult({
    required String playerId,
    required DateTime now,
    required int score,
  }) async {
    final data = await loadDaily(playerId);
    final today = dayKey(now);
    if (data['lastDay'] == today) return data['streak'] as int? ?? 1;
    final yesterday = dayKey(now.subtract(const Duration(days: 1)));
    final streak = data['lastDay'] == yesterday
        ? (data['streak'] as int? ?? 0) + 1
        : 1;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _dailyKey(playerId),
      jsonEncode({'lastDay': today, 'streak': streak, 'score': score}),
    );
    return streak;
  }
}
