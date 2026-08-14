import 'package:brain_adventure/data/adult_challenge_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('نسخة الكبار تحتوي 6 مجالات و10 مستويات من 5 أسئلة', () {
    final categories = buildAdultCategories();
    expect(categories, hasLength(6));
    for (final category in categories) {
      expect(category.questions, hasLength(50));
      for (var level = 1; level <= 10; level++) {
        expect(adultLevelQuestions(category, level), hasLength(5));
      }
    }
  });

  test('معرّفات وصياغات أسئلة الكبار غير مكررة داخل كل مجال', () {
    for (final category in buildAdultCategories()) {
      expect(category.questions.map((item) => item.id).toSet(), hasLength(50));
      expect(
        category.questions.map((item) => item.question).toSet(),
        hasLength(50),
      );
    }
  });
}
