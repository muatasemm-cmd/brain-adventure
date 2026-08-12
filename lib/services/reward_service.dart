import '../models/adventure_progress.dart';
import '../models/player.dart';
import '../models/reward_item.dart';
import 'adventure_progress_storage.dart';
import 'player_storage.dart';

enum RewardAction { purchased, equipped, insufficientCoins }

class RewardResult {
  final RewardAction action;
  final Player player;
  final AdventureProgress progress;

  const RewardResult({
    required this.action,
    required this.player,
    required this.progress,
  });
}

class RewardService {
  static Future<RewardResult> buyOrEquip({
    required Player player,
    required AdventureProgress progress,
    required RewardItem reward,
  }) async {
    final owned = player.ownedRewardIds.contains(reward.id);
    if (!owned && progress.coins < reward.cost) {
      return RewardResult(
        action: RewardAction.insufficientCoins,
        player: player,
        progress: progress,
      );
    }

    var updatedPlayer = player;
    var updatedProgress = progress;
    var action = RewardAction.equipped;
    if (!owned) {
      updatedPlayer = player.copyWith(
        ownedRewardIds: [...player.ownedRewardIds, reward.id],
      );
      updatedProgress = progress.copyWith(coins: progress.coins - reward.cost);
      await AdventureProgressStorage.save(player.id, updatedProgress);
      action = RewardAction.purchased;
    }
    if (reward.category != RewardCategory.room) {
      updatedPlayer = updatedPlayer.copyWith(equippedRewardId: reward.id);
    }
    await PlayerStorage.updatePlayer(updatedPlayer);
    return RewardResult(
      action: action,
      player: updatedPlayer,
      progress: updatedProgress,
    );
  }
}
