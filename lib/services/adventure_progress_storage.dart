import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adventure_progress.dart';
import '../models/learning_challenge.dart';

class AdventureProgressStorage {
  static String _key(String playerId) => 'forest_progress_v1_$playerId';

  static Future<AdventureProgress> load(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_key(playerId));
    if (encoded == null) return const AdventureProgress();
    return AdventureProgress.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  static Future<void> save(String playerId, AdventureProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(playerId), jsonEncode(progress.toJson()));
  }

  static Future<AdventureProgress> recordAnswer({
    required String playerId,
    required LearningChallenge challenge,
    required bool correct,
    required int stageNumber,
    required bool stageCompleted,
  }) async {
    final current = await load(playerId);
    final subject = challenge.subject.name;
    final attempts = Map<String, int>.from(current.attemptsBySubject)
      ..update(subject, (value) => value + 1, ifAbsent: () => 1);
    final correctAnswers = Map<String, int>.from(current.correctBySubject);
    if (correct) {
      correctAnswers.update(subject, (value) => value + 1, ifAbsent: () => 1);
    }

    final completed = Set<String>.from(current.completedChallenges);
    final firstCompletion = correct && completed.add(challenge.id);
    final updated = current.copyWith(
      stars: current.stars + (firstCompletion && correct ? 1 : 0),
      coins: current.coins + (firstCompletion ? (correct ? 10 : 5) : 0),
      crystals: current.crystals + (stageCompleted && firstCompletion ? 1 : 0),
      completedChallenges: completed,
      correctBySubject: correctAnswers,
      attemptsBySubject: attempts,
    );
    await save(playerId, updated);
    return updated;
  }

  static Future<void> delete(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(playerId));
  }

  static Future<void> addPlayTime(String playerId, Duration duration) async {
    if (duration.inSeconds < 1) return;
    final current = await load(playerId);
    await save(
      playerId,
      current.copyWith(
        totalPlaySeconds: current.totalPlaySeconds + duration.inSeconds,
        lastPlayedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}
