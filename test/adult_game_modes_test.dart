import 'package:brain_adventure/services/adult_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('المراجعة تحفظ السؤال الخاطئ وتزيله عند الإتقان', () async {
    await AdultStorage.recordMistake('adult_test', 'arabic_1_1');
    expect(
      await AdultStorage.loadMistakes('adult_test'),
      contains('arabic_1_1'),
    );
    await AdultStorage.masterQuestion('adult_test', 'arabic_1_1');
    expect(await AdultStorage.loadMistakes('adult_test'), isEmpty);
  });

  test('التحدي اليومي يزيد السلسلة في الأيام المتتالية', () async {
    final first = await AdultStorage.recordDailyResult(
      playerId: 'adult_test',
      now: DateTime(2026, 8, 14),
      score: 7,
    );
    final second = await AdultStorage.recordDailyResult(
      playerId: 'adult_test',
      now: DateTime(2026, 8, 15),
      score: 8,
    );
    expect(first, 1);
    expect(second, 2);
  });

  test('يحفظ تحديد المستوى وبلاغ السؤال', () async {
    await AdultStorage.savePlacement('adult_test', 5);
    expect(await AdultStorage.loadPlacement('adult_test'), 5);

    await AdultStorage.reportQuestion(
      playerId: 'adult_test',
      questionId: 'arabic_1_1',
      question: 'سؤال تجريبي',
      reason: 'الإجابة غير صحيحة',
    );
    final reports = await AdultStorage.loadReports('adult_test');
    expect(reports, hasLength(1));
    expect(reports.single['questionId'], 'arabic_1_1');
  });
}
