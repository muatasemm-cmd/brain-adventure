import 'package:brain_adventure/data/subject_stage_data.dart';
import 'package:brain_adventure/models/subject_adventure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('كل مادة تحتوي 20 مرحلة وكل مرحلة 5 أسئلة', () {
    for (final subject in subjectAdventures) {
      final stages = subjectStagesFor(adventure: subject, age: 9);
      expect(stages.length, 20);
      expect(stages.every((stage) => stage.challenges.length == 5), isTrue);
      expect(stages.expand((stage) => stage.challenges).length, 100);
      expect(
        stages
            .expand((stage) => stage.challenges)
            .every((challenge) => challenge.subject == subject.subject),
        isTrue,
      );
    }
  });

  test('أسئلة الرياضيات تتغير حسب العمر', () {
    final math = subjectAdventures.first;
    final young = subjectStagesFor(
      adventure: math,
      age: 6,
    ).first.challenges.first;
    final older = subjectStagesFor(
      adventure: math,
      age: 12,
    ).first.challenges.first;
    expect(young.question, isNot(older.question));
    expect(young.correctAnswer, isNot(older.correctAnswer));
  });
}
