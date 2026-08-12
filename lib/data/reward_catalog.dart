import '../models/reward_item.dart';

const rewardCatalog = [
  RewardItem(
    id: 'explorer_hat',
    name: 'قبعة المستكشف',
    icon: '🤠',
    cost: 20,
    category: RewardCategory.hat,
  ),
  RewardItem(
    id: 'magic_hat',
    name: 'قبعة السحر',
    icon: '🎩',
    cost: 35,
    category: RewardCategory.hat,
  ),
  RewardItem(
    id: 'cool_glasses',
    name: 'نظارات الحماس',
    icon: '😎',
    cost: 25,
    category: RewardCategory.glasses,
  ),
  RewardItem(
    id: 'owl_friend',
    name: 'البومة الحكيمة',
    icon: '🦉',
    cost: 50,
    category: RewardCategory.companion,
  ),
  RewardItem(
    id: 'fox_friend',
    name: 'الثعلب اللطيف',
    icon: '🦊',
    cost: 60,
    category: RewardCategory.companion,
  ),
  RewardItem(
    id: 'telescope',
    name: 'تلسكوب الغرفة',
    icon: '🔭',
    cost: 45,
    category: RewardCategory.room,
  ),
  RewardItem(
    id: 'bookshelf',
    name: 'مكتبة صغيرة',
    icon: '📚',
    cost: 30,
    category: RewardCategory.room,
  ),
  RewardItem(
    id: 'fish_tank',
    name: 'حوض أسماك',
    icon: '🐠',
    cost: 55,
    category: RewardCategory.room,
  ),
];
