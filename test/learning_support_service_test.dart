import 'package:brain_adventure/models/learning_challenge.dart';
import 'package:brain_adventure/services/learning_support_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('يحفظ مستوى تحديد المستوى', () async {
    await LearningSupportService.savePlacementLevel('child', 3);
    expect(await LearningSupportService.loadPlacementLevel('child'), 3);
  });

  test('يسجل الخطأ للمراجعة ثم يزيله عند الإتقان', () async {
    const challenge = LearningChallenge(
      id: 'q1',
      type: ChallengeType.multipleChoice,
      subject: LearningSubject.math,
      title: 'جمع',
      question: '2 + 2',
      options: ['3', '4'],
      correctAnswer: '4',
      hints: ['عد'],
      explanation: '4',
      difficulty: 1,
    );
    await LearningSupportService.recordMistake('child', challenge);
    expect(
      (await LearningSupportService.loadReview('child')).single.mistakes,
      1,
    );
    await LearningSupportService.resolveReview('child', challenge.id);
    expect(await LearningSupportService.loadReview('child'), isEmpty);
  });

  test('الإتقان يحتاج إجابتين صحيحتين متتاليتين', () async {
    const challenge = LearningChallenge(
      id: 'mastery-q',
      type: ChallengeType.multipleChoice,
      subject: LearningSubject.math,
      title: 'جمع',
      question: '2 + 3',
      options: ['4', '5'],
      correctAnswer: '5',
      hints: ['عد'],
      explanation: '5',
      difficulty: 1,
    );
    await LearningSupportService.recordMistake('child', challenge);
    expect(
      await LearningSupportService.recordReviewAnswer(
        'child',
        challenge.id,
        true,
      ),
      isFalse,
    );
    expect(
      (await LearningSupportService.loadReview('child')).single.masteryCorrect,
      1,
    );
    expect(
      await LearningSupportService.recordReviewAnswer(
        'child',
        challenge.id,
        true,
      ),
      isTrue,
    );
    expect(await LearningSupportService.loadReview('child'), isEmpty);
  });

  test('يفتح بطاقة كل 15 سؤالًا دون تكرار', () async {
    expect(
      await LearningSupportService.unlockCardForProgress('child', 14),
      isNull,
    );
    expect(
      await LearningSupportService.unlockCardForProgress('child', 15),
      isNotNull,
    );
    expect(
      await LearningSupportService.unlockCardForProgress('child', 15),
      isNull,
    );
  });
}
