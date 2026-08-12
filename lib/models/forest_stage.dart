import 'learning_challenge.dart';

class ForestStage {
  final int number;
  final String name;
  final String icon;
  final String description;
  final List<LearningChallenge> challenges;

  const ForestStage({
    required this.number,
    required this.name,
    required this.icon,
    required this.description,
    required this.challenges,
  });
}
