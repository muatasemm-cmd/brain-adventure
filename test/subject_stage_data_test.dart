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

  test('أسئلة كل المواد تختلف بين أعمار 8 و10 و12', () {
    for (final subject in subjectAdventures) {
      final questions = [
        for (final age in [8, 10, 12])
          subjectStagesFor(
            adventure: subject,
            age: age,
          ).first.challenges.first.question,
      ];
      expect(questions.toSet().length, 3, reason: subject.title);
    }
  });

  test('لا يتكرر نص أي سؤال بين المراحل العشرين في كل مادة', () {
    for (final subject in subjectAdventures) {
      final allQuestions = subjectStagesFor(adventure: subject, age: 9)
          .expand((stage) => stage.challenges)
          .map((challenge) => challenge.question)
          .toList();
      expect(allQuestions.length, 100);
      expect(
        allQuestions.toSet().length,
        100,
        reason: 'وجد تكرار في مادة ${subject.title}',
      );
    }
  });

  test('لا تتطابق مجموعة أسئلة مرحلتين في أي مادة', () {
    for (final subject in subjectAdventures) {
      final stages = subjectStagesFor(adventure: subject, age: 9);
      final signatures = stages
          .map((stage) => stage.challenges.map((q) => q.question).join('|'))
          .toSet();
      expect(signatures.length, 20, reason: subject.title);
    }
  });
}
