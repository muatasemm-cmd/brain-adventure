import 'package:flutter/material.dart';

import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import '../services/online_content_service.dart';
import '../data/adult_challenge_data.dart';
import 'adult_levels_screen.dart';
import 'adult_special_challenge_screen.dart';

class AdultDashboardScreen extends StatefulWidget {
  final AdultPlayer player;

  const AdultDashboardScreen({super.key, required this.player});

  @override
  State<AdultDashboardScreen> createState() => _AdultDashboardScreenState();
}

class _AdultDashboardScreenState extends State<AdultDashboardScreen> {
  List<AdultCategory> categories = const [];
  Map<String, int> progress = {};
  OnlineContentResult? onlineContent;
  bool contentLoading = true;
  Map<String, dynamic> daily = {};
  Set<String> mistakes = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([
      AdultStorage.loadProgress(widget.player.id),
      OnlineContentService.load(forceRefresh: true),
      AdultStorage.loadDaily(widget.player.id),
      AdultStorage.loadMistakes(widget.player.id),
    ]);
    progress = results[0] as Map<String, int>;
    onlineContent = results[1] as OnlineContentResult;
    categories = onlineContent!.categories;
    daily = results[2] as Map<String, dynamic>;
    mistakes = results[3] as Set<String>;
    contentLoading = false;
    if (mounted) setState(() {});
  }

  int completedFor(String categoryId) => [
    for (var level = 1; level <= adultLevelCount; level++)
      progress['$categoryId:$level'],
  ].whereType<int>().length;

  @override
  Widget build(BuildContext context) {
    final completed = progress.length;
    final points = progress.values.fold<int>(
      0,
      (sum, score) => sum + score * 20,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('مرحبًا ${widget.player.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث المحتوى',
            onPressed: contentLoading
                ? null
                : () async {
                    setState(() => contentLoading = true);
                    await load();
                  },
            icon: contentLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: '$points', label: 'نقطة'),
                  _Stat(value: '$completed/200', label: 'مرحلة'),
                  _Stat(value: widget.player.level, label: 'البداية'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  onlineContent?.fromInternet == true
                      ? Icons.cloud_done_rounded
                      : Icons.offline_bolt_rounded,
                  size: 18,
                  color: onlineContent?.fromInternet == true
                      ? const Color(0xFF4ADE80)
                      : Colors.white60,
                ),
                const SizedBox(width: 7),
                Text(
                  onlineContent == null
                      ? 'جاري فحص تحديثات المحتوى...'
                      : '${onlineContent!.message} • إصدار ${onlineContent!.version}',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'أوضاع اللعب',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 650 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _ModeCard(
                  icon: '☀️',
                  title: 'تحدي اليوم',
                  subtitle: '🔥 ${daily['streak'] ?? 0} أيام',
                  onTap: () => openMode(AdultPlayMode.daily),
                ),
                _ModeCard(
                  icon: '⏱️',
                  title: 'تحدي الوقت',
                  subtitle: '60 ثانية',
                  onTap: () => openMode(AdultPlayMode.timed),
                ),
                _ModeCard(
                  icon: '❤️',
                  title: 'وضع البقاء',
                  subtitle: '3 محاولات',
                  onTap: () => openMode(AdultPlayMode.survival),
                ),
                _ModeCard(
                  icon: '🔁',
                  title: 'مراجعة ذكية',
                  subtitle: '${mistakes.length} أسئلة',
                  onTap: () => openMode(AdultPlayMode.review),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _Achievement(
                  label: 'أول خطوة',
                  icon: '⭐',
                  unlocked: progress.isNotEmpty,
                ),
                _Achievement(
                  label: 'متحدٍ نشيط',
                  icon: '🏅',
                  unlocked: progress.length >= 10,
                ),
                _Achievement(
                  label: 'ثبات 3 أيام',
                  icon: '🔥',
                  unlocked: (daily['streak'] as int? ?? 0) >= 3,
                ),
                _Achievement(
                  label: 'ذاكرة صافية',
                  icon: '🧠',
                  unlocked: progress.isNotEmpty && mistakes.isEmpty,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر مجال التحدي',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 170,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final done = completedFor(category.id);
                return _CategoryCard(
                  category: category,
                  completed: done,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdultLevelsScreen(
                          player: widget.player,
                          category: category,
                        ),
                      ),
                    );
                    await load();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openMode(AdultPlayMode mode) async {
    if (categories.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdultSpecialChallengeScreen(
          player: widget.player,
          categories: categories,
          mode: mode,
        ),
      ),
    );
    await load();
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ],
  );
}

class _CategoryCard extends StatelessWidget {
  final AdultCategory category;
  final int completed;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.completed,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF1E293B),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 38)),
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              category.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: completed / adultLevelCount,
              color: const Color(0xFFA78BFA),
              backgroundColor: Colors.white12,
            ),
            const SizedBox(height: 5),
            Text(
              '$completed من $adultLevelCount',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF312E81),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Achievement extends StatelessWidget {
  final String label;
  final String icon;
  final bool unlocked;

  const _Achievement({
    required this.label,
    required this.icon,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Text(unlocked ? icon : '🔒'),
    label: Text(label),
    backgroundColor: unlocked
        ? const Color(0xFFFDE68A)
        : const Color(0xFF334155),
    labelStyle: TextStyle(
      color: unlocked ? const Color(0xFF422006) : Colors.white54,
      fontWeight: FontWeight.bold,
    ),
  );
}
