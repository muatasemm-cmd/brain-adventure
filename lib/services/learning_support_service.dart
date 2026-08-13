import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_challenge.dart';

class ReviewEntry {
  final String challengeId;
  final String subject;
  final String question;
  final List<String> options;
  final String answer;
  final int mistakes;
  final int masteryCorrect;

  const ReviewEntry({
    required this.challengeId,
    required this.subject,
    required this.question,
    required this.options,
    required this.answer,
    required this.mistakes,
    this.masteryCorrect = 0,
  });

  Map<String, Object> toJson() => {
    'challengeId': challengeId,
    'subject': subject,
    'question': question,
    'options': options,
    'answer': answer,
    'mistakes': mistakes,
    'masteryCorrect': masteryCorrect,
  };

  factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
    challengeId: json['challengeId'] as String,
    subject: json['subject'] as String,
    question: json['question'] as String,
    options: [
      for (final item in json['options'] as List? ?? const []) item.toString(),
    ],
    answer: json['answer'] as String,
    mistakes: json['mistakes'] as int? ?? 1,
    masteryCorrect: json['masteryCorrect'] as int? ?? 0,
  );
}

class LearningSupportService {
  static String _placementKey(String playerId, String subject) =>
      'placement_level_${playerId}_$subject';
  static String _reviewKey(String playerId) => 'smart_review_$playerId';
  static String _cardsKey(String playerId) => 'collection_cards_$playerId';

  static Future<int?> loadPlacementLevel(
    String playerId, [
    String subject = 'math',
  ]) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_placementKey(playerId, subject)) ??
        preferences.getInt('placement_level_$playerId');
  }

  static Future<void> savePlacementLevel(
    String playerId,
    int level, [
    String subject = 'math',
  ]) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _placementKey(playerId, subject),
      level.clamp(1, 3),
    );
  }

  static Future<Map<String, int>> loadPlacementLevels(String playerId) async {
    const subjects = [
      'math',
      'science',
      'culture',
      'logic',
      'arabic',
      'history',
      'geography',
    ];
    return {
      for (final subject in subjects)
        subject: await loadPlacementLevel(playerId, subject) ?? 2,
    };
  }

  static Future<bool> hasPlacement(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_placementKey(playerId, 'math')) ||
        preferences.containsKey('placement_level_$playerId');
  }

  static Future<List<ReviewEntry>> loadReview(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_reviewKey(playerId));
    if (encoded == null) return const [];
    return (jsonDecode(encoded) as List)
        .map((item) => ReviewEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> recordMistake(
    String playerId,
    LearningChallenge challenge,
  ) async {
    final entries = (await loadReview(playerId)).toList();
    final index = entries.indexWhere(
      (item) => item.challengeId == challenge.id,
    );
    final previous = index < 0 ? null : entries[index];
    final entry = ReviewEntry(
      challengeId: challenge.id,
      subject: challenge.subject.name,
      question: _rephrase(challenge.question),
      options: challenge.options,
      answer: challenge.correctAnswer,
      mistakes: (previous?.mistakes ?? 0) + 1,
      masteryCorrect: 0,
    );
    if (index < 0) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _reviewKey(playerId),
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> resolveReview(String playerId, String challengeId) async {
    final entries = (await loadReview(
      playerId,
    )).where((item) => item.challengeId != challengeId).toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _reviewKey(playerId),
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
  }

  /// Returns true when the skill is mastered (two correct review attempts).
  static Future<bool> recordReviewAnswer(
    String playerId,
    String challengeId,
    bool correct,
  ) async {
    final entries = (await loadReview(playerId)).toList();
    final index = entries.indexWhere((item) => item.challengeId == challengeId);
    if (index < 0) return false;
    final old = entries[index];
    final score = correct ? old.masteryCorrect + 1 : 0;
    if (score >= 2) {
      entries.removeAt(index);
    } else {
      entries[index] = ReviewEntry(
        challengeId: old.challengeId,
        subject: old.subject,
        question: old.question,
        options: old.options,
        answer: old.answer,
        mistakes: old.mistakes,
        masteryCorrect: score,
      );
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _reviewKey(playerId),
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
    return score >= 2;
  }

  static String _rephrase(String question) => 'فكّر بطريقة جديدة: $question';

  static Future<Set<String>> loadCards(String playerId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_cardsKey(playerId))?.toSet() ??
        <String>{};
  }

  static Future<String?> unlockCardForProgress(
    String playerId,
    int completed,
  ) async {
    const cards = [
      'fox',
      'planet',
      'owl',
      'robot',
      'dolphin',
      'pyramid',
      'dragon',
      'telescope',
    ];
    if (completed == 0 || completed % 15 != 0) return null;
    final cardsOwned = await loadCards(playerId);
    final card = cards[(completed ~/ 15 - 1) % cards.length];
    if (!cardsOwned.add(card)) return null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_cardsKey(playerId), cardsOwned.toList());
    return card;
  }
}
