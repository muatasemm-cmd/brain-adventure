enum SurpriseRewardType { coins, stars, item }

class SurpriseReward {
  final SurpriseRewardType type;
  final int amount;
  final String? rewardId;
  final String title;
  final String icon;

  const SurpriseReward({
    required this.type,
    required this.title,
    required this.icon,
    this.amount = 0,
    this.rewardId,
  });
}
