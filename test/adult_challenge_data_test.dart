import 'package:brain_adventure/data/adult_challenge_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('نسخة الكبار تحتوي 10 مجالات و20 مرحلة من 5 أسئلة', () {
    final categories = buildAdultCategories();
    expect(categories, hasLength(10));
    for (final category in categories) {
      expect(category.questions, hasLength(100));
      for (var level = 1; level <= 20; level++) {
        expect(adultLevelQuestions(category, level), hasLength(5));
      }
    }
  });

  test('معرّفات وصياغات أسئلة الكبار غير مكررة داخل كل مجال', () {
    for (final category in buildAdultCategories()) {
      expect(category.questions.map((item) => item.id).toSet(), hasLength(100));
      expect(
        category.questions.map((item) => item.question).toSet(),
        hasLength(100),
      );
    }
  });

  test('اختبار تحديد المستوى يحتوي 15 سؤالًا مختلفًا', () {
    final questions = adultPlacementQuestions(buildAdultCategories());
    expect(questions, hasLength(15));
    expect(questions.map((item) => item.id).toSet(), hasLength(15));
    expect(questions.map((item) => item.question).toSet(), hasLength(15));

    // Remove the challenge frame to ensure two entries do not hide the same
    // base question behind different level wording.
    final baseQuestions = questions
        .map((item) => item.question.split(': ').last)
        .toSet();
    expect(baseQuestions, hasLength(15));
  });
}
