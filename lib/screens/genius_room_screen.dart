import 'package:flutter/material.dart';

import '../data/reward_catalog.dart';
import '../models/adventure_progress.dart';
import '../models/player.dart';
import '../models/reward_item.dart';
import '../services/adventure_progress_storage.dart';
import '../services/player_storage.dart';
import '../services/reward_service.dart';

class GeniusRoomScreen extends StatefulWidget {
  final Player player;

  const GeniusRoomScreen({super.key, required this.player});

  @override
  State<GeniusRoomScreen> createState() => _GeniusRoomScreenState();
}

class _GeniusRoomScreenState extends State<GeniusRoomScreen> {
  Player? player;
  AdventureProgress? progress;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final players = await PlayerStorage.loadPlayers();
    final latest = players.firstWhere(
      (item) => item.id == widget.player.id,
      orElse: () => widget.player,
    );
    final loadedProgress = await AdventureProgressStorage.load(
      widget.player.id,
    );
    if (mounted) {
      setState(() {
        player = latest;
        progress = loadedProgress;
      });
    }
  }

  RewardItem? rewardById(String? id) {
    if (id == null) return null;
    for (final reward in rewardCatalog) {
      if (reward.id == id) return reward;
    }
    return null;
  }

  Future<void> buyOrEquip(RewardItem reward) async {
    final currentPlayer = player!;
    final currentProgress = progress!;
    final owned = currentPlayer.ownedRewardIds.contains(reward.id);
    if (!owned && currentProgress.coins < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اجمع عملات أكثر بإكمال تحديات الغابة 🪙',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    if (!owned) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            '${reward.icon} ${reward.name}',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'شراء هذه المكافأة مقابل ${reward.cost} عملة؟',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('شراء'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final result = await RewardService.buyOrEquip(
      player: currentPlayer,
      progress: currentProgress,
      reward: reward,
    );
    if (mounted) {
      setState(() {
        player = result.player;
        progress = result.progress;
      });
    }
  }

  List<(String, String, bool)> achievements(AdventureProgress value) {
    final correct = value.correctBySubject.values.fold(0, (a, b) => a + b);
    final attempts = value.attemptsBySubject.values.fold(0, (a, b) => a + b);
    return [
      ('🌟', 'أول إجابة صحيحة', correct >= 1),
      ('🔥', 'خمس إجابات صحيحة', correct >= 5),
      ('💎', 'جامع البلورات', value.crystals >= 1),
      ('🌳', 'منقذ الغابة', value.crystals >= 5),
      ('🎯', 'دقة عالية', attempts >= 5 && correct / attempts >= .8),
      ('🛍️', 'أول مكافأة', player!.ownedRewardIds.isNotEmpty),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = player;
    final currentProgress = progress;
    if (currentPlayer == null || currentProgress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final equipped = rewardById(currentPlayer.equippedRewardId);
    final roomRewards = rewardCatalog.where(
      (reward) =>
          reward.category == RewardCategory.room &&
          currentPlayer.ownedRewardIds.contains(reward.id),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('🏠 غرفة ${currentPlayer.name}'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '🪙 ${currentProgress.coins}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE9FE), Color(0xFFFCE7F3)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Text(
                      currentPlayer.avatar,
                      style: const TextStyle(fontSize: 100),
                    ),
                    if (equipped != null)
                      Text(equipped.icon, style: const TextStyle(fontSize: 45)),
                  ],
                ),
                Text(
                  equipped == null
                      ? 'اختر مكافأة لتخصيص شخصيتك'
                      : 'يرتدي: ${equipped.name}',
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  children: [
                    for (final reward in roomRewards)
                      Tooltip(
                        message: reward.name,
                        child: Text(
                          reward.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '🎁 متجر المكافآت',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemCount: rewardCatalog.length,
            itemBuilder: (context, index) {
              final reward = rewardCatalog[index];
              final owned = currentPlayer.ownedRewardIds.contains(reward.id);
              final equippedNow = currentPlayer.equippedRewardId == reward.id;
              return InkWell(
                onTap: () => buyOrEquip(reward),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: equippedNow
                        ? const Color(0xFFDDD6FE)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: equippedNow
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(reward.icon, style: const TextStyle(fontSize: 36)),
                      Text(
                        reward.name,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        equippedNow
                            ? 'مُستخدم الآن'
                            : owned
                            ? 'مملوك'
                            : '🪙 ${reward.cost}',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            '🏅 الإنجازات',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final achievement in achievements(currentProgress))
            ListTile(
              leading: Text(
                achievement.$3 ? achievement.$1 : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                achievement.$2,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achievement.$3 ? null : Colors.grey,
                ),
              ),
              trailing: achievement.$3
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
        ],
      ),
    );
  }
}
