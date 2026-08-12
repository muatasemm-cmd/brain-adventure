import 'package:brain_adventure/data/reward_catalog.dart';
import 'package:brain_adventure/models/adventure_progress.dart';
import 'package:brain_adventure/services/player_storage.dart';
import 'package:brain_adventure/services/reward_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('يشتري المكافأة ويخصم العملات مرة واحدة ثم يجهزها', () async {
    final player = (await PlayerStorage.addPlayer(
      name: 'لاعب الاختبار',
      age: 9,
      avatar: '🧑',
    )).first;
    const progress = AdventureProgress(coins: 40);
    final reward = rewardCatalog.first;

    var result = await RewardService.buyOrEquip(
      player: player,
      progress: progress,
      reward: reward,
    );
    expect(result.action, RewardAction.purchased);
    expect(result.progress.coins, 40 - reward.cost);
    expect(result.player.ownedRewardIds, contains(reward.id));
    expect(result.player.equippedRewardId, reward.id);

    result = await RewardService.buyOrEquip(
      player: result.player,
      progress: result.progress,
      reward: reward,
    );
    expect(result.action, RewardAction.equipped);
    expect(result.progress.coins, 40 - reward.cost);
  });

  test('يرفض الشراء إذا لم تكف العملات', () async {
    final player = (await PlayerStorage.addPlayer(
      name: 'لاعب الاختبار',
      age: 9,
      avatar: '🧑',
    )).first;
    const progress = AdventureProgress(coins: 0);
    final result = await RewardService.buyOrEquip(
      player: player,
      progress: progress,
      reward: rewardCatalog.last,
    );
    expect(result.action, RewardAction.insufficientCoins);
    expect(result.player.ownedRewardIds, isEmpty);
    expect(result.progress.coins, 0);
  });
}
