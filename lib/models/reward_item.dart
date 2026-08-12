enum RewardCategory { hat, glasses, companion, room }

class RewardItem {
  final String id;
  final String name;
  final String icon;
  final int cost;
  final RewardCategory category;

  const RewardItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    required this.category,
  });
}
