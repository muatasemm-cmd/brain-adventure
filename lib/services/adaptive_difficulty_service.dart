import '../models/adventure_progress.dart';
import '../models/learning_challenge.dart';

enum LearningPace { guided, balanced, advanced }

class AdaptiveDifficulty {
  final int recommendedLevel;
  final LearningPace pace;
  final double? mastery;

  const AdaptiveDifficulty({
    required this.recommendedLevel,
    required this.pace,
    required this.mastery,
  });

  bool shouldShowEarlyHint(int challengeDifficulty) =>
      pace == LearningPace.guided || challengeDifficulty > recommendedLevel;

  String get label => switch (pace) {
    LearningPace.guided => 'نتعلم خطوة خطوة',
    LearningPace.balanced => 'تحدٍّ مناسب لك',
    LearningPace.advanced => 'مستوى الأبطال',
  };
}

class AdaptiveDifficultyService {
  const AdaptiveDifficultyService._();

  static AdaptiveDifficulty evaluate({
    required int age,
    required LearningSubject subject,
    required AdventureProgress progress,
  }) {
    final attempts = progress.attemptsBySubject[subject.name] ?? 0;
    final correct = progress.correctBySubject[subject.name] ?? 0;
    final mastery = attempts == 0 ? null : correct / attempts;
    final ageLevel = ((age - 5) / 2).ceil().clamp(1, 5);

    var modifier = 0;
    var pace = LearningPace.balanced;
    if (attempts >= 3 && mastery! < .6) {
      modifier = -1;
      pace = LearningPace.guided;
    } else if (attempts >= 3 && mastery! >= .85) {
      modifier = 1;
      pace = LearningPace.advanced;
    }

    return AdaptiveDifficulty(
      recommendedLevel: (ageLevel + modifier).clamp(1, 5),
      pace: pace,
      mastery: mastery,
    );
  }
}
