class AdultQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;

  const AdultQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

class AdultCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<AdultQuestion> questions;

  const AdultCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.questions,
  });
}
