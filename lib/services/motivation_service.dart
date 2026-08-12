import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adventure_progress.dart';
import '../models/learning_challenge.dart';
import 'adventure_progress_storage.dart';

class DailyMissionStatus {
  final int answers;
  final Set<String> subjects;
  final int correctWithoutMistake;
  final bool claimed;

  const DailyMissionStatus({
    this.answers = 0,
    this.subjects = const {},
    this.correctWithoutMistake = 0,
    this.claimed = false,
  });

  bool get complete =>
      answers >= 10 && subjects.isNotEmpty && correctWithoutMistake >= 3;

  Map<String, Object> toJson() => {
    'answers': answers,
    'subjects': subjects.toList(),
    'correctWithoutMistake': correctWithoutMistake,
    'claimed': claimed,
  };

  factory DailyMissionStatus.fromJson(Map<String, dynamic> json) =>
      DailyMissionStatus(
        answers: json['answers'] as int? ?? 0,
        subjects: {
          for (final value in json['subjects'] as List? ?? const [])
            value.toString(),
        },
        correctWithoutMistake: json['correctWithoutMistake'] as int? ?? 0,
        claimed: json['claimed'] as bool? ?? false,
      );
}

class MilestoneReward {
  final int stage;
  final String tier;
  final String icon;
  final int coins;
  final int stars;

  const MilestoneReward(
    this.stage,
    this.tier,
    this.icon,
    this.coins,
    this.stars,
  );
}

class MotivationService {
  static const milestones = [
    MilestoneReward(5, 'برونزي', '🥉', 30, 3),
    MilestoneReward(10, 'فضي', '🥈', 50, 5),
    MilestoneReward(15, 'ذهبي', '🥇', 80, 8),
    MilestoneReward(20, 'أسطوري', '👑', 150, 15),
  ];

  static String _day(DateTime now) => '${now.year}-${now.month}-${now.day}';
  static String _missionKey(String playerId, DateTime now) =>
      'missions_${playerId}_${_day(now)}';
  static String _chestKey(
    String playerId,
    LearningSubject subject,
    int stage,
  ) => 'milestone_${playerId}_${subject.name}_$stage';

  static Future<DailyMissionStatus> loadMissions(
    String playerId,
    DateTime now,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_missionKey(playerId, now));
    if (encoded == null) return const DailyMissionStatus();
    return DailyMissionStatus.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  static Future<void> recordCorrectAnswer({
    required String playerId,
    required LearningSubject subject,
    required DateTime now,
    required bool firstTry,
  }) async {
    final current = await loadMissions(playerId, now);
    final updated = DailyMissionStatus(
      answers: current.answers + 1,
      subjects: {...current.subjects, subject.name},
      correctWithoutMistake: current.correctWithoutMistake + (firstTry ? 1 : 0),
      claimed: current.claimed,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _missionKey(playerId, now),
      jsonEncode(updated.toJson()),
    );
  }

  static Future<bool> claimDailyMissions(String playerId, DateTime now) async {
    final current = await loadMissions(playerId, now);
    if (!current.complete || current.claimed) return false;
    final progress = await AdventureProgressStorage.load(playerId);
    await AdventureProgressStorage.save(
      playerId,
      progress.copyWith(coins: progress.coins + 60, stars: progress.stars + 5),
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _missionKey(playerId, now),
      jsonEncode(
        DailyMissionStatus(
          answers: current.answers,
          subjects: current.subjects,
          correctWithoutMistake: current.correctWithoutMistake,
          claimed: true,
        ).toJson(),
      ),
    );
    return true;
  }

  static Future<bool> chestClaimed(
    String playerId,
    LearningSubject subject,
    int stage,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_chestKey(playerId, subject, stage)) ?? false;
  }

  static Future<AdventureProgress?> claimMilestone({
    required String playerId,
    required LearningSubject subject,
    required int stage,
  }) async {
    final reward = milestones.where((item) => item.stage == stage).firstOrNull;
    if (reward == null || await chestClaimed(playerId, subject, stage)) {
      return null;
    }
    final progress = await AdventureProgressStorage.load(playerId);
    final prefix = '${subject.name}_';
    final completed = progress.completedChallenges
        .where((id) => id.startsWith(prefix))
        .length;
    if (completed < stage * 5) {
      return null;
    }
    final updated = progress.copyWith(
      coins: progress.coins + reward.coins,
      stars: progress.stars + reward.stars,
    );
    await AdventureProgressStorage.save(playerId, updated);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_chestKey(playerId, subject, stage), true);
    return updated;
  }

  static ({String icon, String name, int level, int progress, int target})
  petFor(AdventureProgress progress) {
    final xp = progress.completedChallenges.length;
    if (xp < 10) {
      return (
        icon: '🥚',
        name: 'بيضة العبقري',
        level: 1,
        progress: xp,
        target: 10,
      );
    }
    if (xp < 35) {
      return (
        icon: '🐣',
        name: 'فرخ المعرفة',
        level: 2,
        progress: xp - 10,
        target: 25,
      );
    }
    if (xp < 80) {
      return (
        icon: '🦉',
        name: 'البومة الذكية',
        level: 3,
        progress: xp - 35,
        target: 45,
      );
    }
    return (
      icon: '🐉',
      name: 'تنين العباقرة',
      level: 4,
      progress: 1,
      target: 1,
    );
  }
}
