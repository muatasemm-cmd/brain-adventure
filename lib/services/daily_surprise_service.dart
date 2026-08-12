import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/reward_catalog.dart';
import '../models/surprise_reward.dart';
import 'adventure_progress_storage.dart';
import 'parent_settings_storage.dart';
import 'player_storage.dart';

class DailySurpriseStatus {
  final bool available;
  final DateTime nextAvailableAt;

  const DailySurpriseStatus({
    required this.available,
    required this.nextAvailableAt,
  });
}

class DailySurpriseService {
  static String _claimKey(String playerId) => 'daily_surprise_claim_$playerId';

  static Future<DailySurpriseStatus> status({
    required String playerId,
    required DateTime now,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final hour = await ParentSettingsStorage.loadSurpriseHour();
    final todayOpening = DateTime(now.year, now.month, now.day, hour);
    final lastClaim = DateTime.tryParse(
      preferences.getString(_claimKey(playerId)) ?? '',
    );
    final claimedToday =
        lastClaim != null &&
        lastClaim.year == now.year &&
        lastClaim.month == now.month &&
        lastClaim.day == now.day;
    final available = !now.isBefore(todayOpening) && !claimedToday;
    final next = available
        ? todayOpening
        : now.isBefore(todayOpening)
        ? todayOpening
        : todayOpening.add(const Duration(days: 1));
    return DailySurpriseStatus(available: available, nextAvailableAt: next);
  }

  static Future<SurpriseReward?> claim({
    required String playerId,
    required DateTime now,
    Random? random,
  }) async {
    final currentStatus = await status(playerId: playerId, now: now);
    if (!currentStatus.available) return null;
    final generator = random ?? Random();
    final players = await PlayerStorage.loadPlayers();
    final index = players.indexWhere((player) => player.id == playerId);
    if (index < 0) return null;
    var player = players[index];
    var progress = await AdventureProgressStorage.load(playerId);
    SurpriseReward reward;

    final unowned = rewardCatalog
        .where((item) => !player.ownedRewardIds.contains(item.id))
        .toList();
    final roll = generator.nextInt(100);
    if (roll >= 85 && unowned.isNotEmpty) {
      final item = unowned[generator.nextInt(unowned.length)];
      player = player.copyWith(
        ownedRewardIds: [...player.ownedRewardIds, item.id],
      );
      await PlayerStorage.updatePlayer(player);
      reward = SurpriseReward(
        type: SurpriseRewardType.item,
        rewardId: item.id,
        title: item.name,
        icon: item.icon,
      );
    } else if (roll >= 55) {
      final stars = 2 + generator.nextInt(4);
      progress = progress.copyWith(stars: progress.stars + stars);
      await AdventureProgressStorage.save(playerId, progress);
      reward = SurpriseReward(
        type: SurpriseRewardType.stars,
        amount: stars,
        title: '$stars نجوم',
        icon: '⭐',
      );
    } else {
      final coins = 15 + generator.nextInt(4) * 5;
      progress = progress.copyWith(coins: progress.coins + coins);
      await AdventureProgressStorage.save(playerId, progress);
      reward = SurpriseReward(
        type: SurpriseRewardType.coins,
        amount: coins,
        title: '$coins عملة',
        icon: '🪙',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_claimKey(playerId), now.toIso8601String());
    return reward;
  }
}
