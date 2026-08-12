enum ChallengeType {
  multipleChoice,
  trueFalse,
  numberInput,
  ordering,
  matching,
  memory,
}

enum LearningSubject { math, science, culture, logic, mixed }

class LearningChallenge {
  final String id;
  final ChallengeType type;
  final LearningSubject subject;
  final String title;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final List<String> hints;
  final String explanation;
  final int difficulty;

  const LearningChallenge({
    required this.id,
    required this.type,
    required this.subject,
    required this.title,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.hints,
    required this.explanation,
    required this.difficulty,
  });
}
