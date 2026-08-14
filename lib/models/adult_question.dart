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

  Map<String, Object> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'answer': answer,
    'explanation': explanation,
  };

  factory AdultQuestion.fromJson(Map<String, dynamic> json) => AdultQuestion(
    id: json['id'] as String,
    question: json['question'] as String,
    options: (json['options'] as List).map((item) => item.toString()).toList(),
    answer: json['answer'] as String,
    explanation: json['explanation'] as String,
  );
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

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'description': description,
    'questions': questions.map((item) => item.toJson()).toList(),
  };

  factory AdultCategory.fromJson(Map<String, dynamic> json) => AdultCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    description: json['description'] as String,
    questions: (json['questions'] as List)
        .map((item) => AdultQuestion.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
