import 'package:brain_adventure/models/adventure_progress.dart';
import 'package:brain_adventure/models/learning_challenge.dart';
import 'package:brain_adventure/services/adventure_progress_storage.dart';
import 'package:brain_adventure/services/motivation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('تكتمل المهام وتمنح مكافأتها مرة واحدة', () async {
    final now = DateTime(2026, 8, 12, 12);
    for (var i = 0; i < 10; i++) {
      await MotivationService.recordCorrectAnswer(
        playerId: 'child',
        subject: LearningSubject.math,
        now: now,
        firstTry: i < 3,
      );
    }
    expect(
      (await MotivationService.loadMissions('child', now)).complete,
      isTrue,
    );
    expect(await MotivationService.claimDailyMissions('child', now), isTrue);
    expect(await MotivationService.claimDailyMissions('child', now), isFalse);
    final progress = await AdventureProgressStorage.load('child');
    expect(progress.coins, 60);
    expect(progress.stars, 5);
  });

  test('صندوق المرحلة لا يتكرر', () async {
    final completed = {
      for (var i = 1; i <= 25; i++)
        'math_2_${(i - 1) ~/ 5 + 1}_q${(i - 1) % 5 + 1}',
    };
    await AdventureProgressStorage.save(
      'child',
      AdventureProgress(completedChallenges: completed),
    );
    expect(
      await MotivationService.claimMilestone(
        playerId: 'child',
        subject: LearningSubject.math,
        stage: 5,
      ),
      isNotNull,
    );
    expect(
      await MotivationService.claimMilestone(
        playerId: 'child',
        subject: LearningSubject.math,
        stage: 5,
      ),
      isNull,
    );
  });

  test('الحيوان المرافق يتطور مع التقدم', () {
    expect(MotivationService.petFor(const AdventureProgress()).icon, '🥚');
    expect(
      MotivationService.petFor(
        AdventureProgress(
          completedChallenges: {for (var i = 0; i < 40; i++) '$i'},
        ),
      ).icon,
      '🦉',
    );
  });
}
