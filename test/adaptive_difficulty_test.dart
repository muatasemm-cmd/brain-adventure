import 'package:brain_adventure/models/adventure_progress.dart';
import 'package:brain_adventure/models/learning_challenge.dart';
import 'package:brain_adventure/services/adaptive_difficulty_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('يقدم دعمًا مبكرًا عند انخفاض الإتقان', () {
    const progress = AdventureProgress(
      attemptsBySubject: {'math': 5},
      correctBySubject: {'math': 2},
    );
    final result = AdaptiveDifficultyService.evaluate(
      age: 9,
      subject: LearningSubject.math,
      progress: progress,
    );
    expect(result.pace, LearningPace.guided);
    expect(result.recommendedLevel, 1);
    expect(result.shouldShowEarlyHint(2), isTrue);
  });

  test('يرفع المستوى عند استمرار التفوق', () {
    const progress = AdventureProgress(
      attemptsBySubject: {'science': 10},
      correctBySubject: {'science': 9},
    );
    final result = AdaptiveDifficultyService.evaluate(
      age: 10,
      subject: LearningSubject.science,
      progress: progress,
    );
    expect(result.pace, LearningPace.advanced);
    expect(result.recommendedLevel, 4);
  });

  test('يبقى متوازنًا قبل توفر بيانات كافية', () {
    final result = AdaptiveDifficultyService.evaluate(
      age: 7,
      subject: LearningSubject.logic,
      progress: const AdventureProgress(),
    );
    expect(result.pace, LearningPace.balanced);
    expect(result.mastery, isNull);
  });
}
