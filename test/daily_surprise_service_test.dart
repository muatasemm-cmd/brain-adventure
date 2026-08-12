import 'dart:math';

import 'package:brain_adventure/models/adventure_progress.dart';
import 'package:brain_adventure/services/adventure_progress_storage.dart';
import 'package:brain_adventure/services/daily_surprise_service.dart';
import 'package:brain_adventure/services/player_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('الصندوق مغلق قبل الثامنة ومتاح بعدها', () async {
    final before = await DailySurpriseService.status(
      playerId: 'child',
      now: DateTime(2026, 8, 12, 19, 59),
    );
    final after = await DailySurpriseService.status(
      playerId: 'child',
      now: DateTime(2026, 8, 12, 20),
    );
    expect(before.available, isFalse);
    expect(after.available, isTrue);
  });

  test('يمنح الجائزة مرة واحدة في اليوم', () async {
    final player = (await PlayerStorage.addPlayer(
      name: 'طفل',
      age: 8,
      avatar: '🧑',
    )).single;
    const starting = AdventureProgress(coins: 5);
    await AdventureProgressStorage.save(player.id, starting);
    final now = DateTime(2026, 8, 12, 20);
    final reward = await DailySurpriseService.claim(
      playerId: player.id,
      now: now,
      random: Random(1),
    );
    final repeated = await DailySurpriseService.claim(
      playerId: player.id,
      now: now.add(const Duration(hours: 1)),
      random: Random(1),
    );
    expect(reward, isNotNull);
    expect(repeated, isNull);
  });
}
