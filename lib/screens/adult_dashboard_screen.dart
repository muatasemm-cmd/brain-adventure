import 'package:flutter/material.dart';

import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import '../services/online_content_service.dart';
import 'adult_quiz_screen.dart';

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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([
      AdultStorage.loadProgress(widget.player.id),
      OnlineContentService.load(forceRefresh: true),
    ]);
    progress = results[0] as Map<String, int>;
    onlineContent = results[1] as OnlineContentResult;
    categories = onlineContent!.categories;
    contentLoading = false;
    if (mounted) setState(() {});
  }

  int completedFor(String categoryId) => [
    for (var level = 1; level <= 10; level++) progress['$categoryId:$level'],
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
                  _Stat(value: '$completed/60', label: 'مستوى'),
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
                  onTap: () => showLevels(category),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLevels(AdultCategory category) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      builder: (sheetContext) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          maxChildSize: .92,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                '${category.icon} ${category.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              for (var level = 1; level <= 10; level++)
                Card(
                  color: const Color(0xFF334155),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('$level')),
                    title: Text(
                      'المستوى $level',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      progress.containsKey('${category.id}:$level')
                          ? 'أفضل نتيجة: ${progress['${category.id}:$level']}/5'
                          : '5 أسئلة',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Icon(
                      progress.containsKey('${category.id}:$level')
                          ? Icons.workspace_premium
                          : Icons.play_circle_outline,
                      color: const Color(0xFFFBBF24),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdultQuizScreen(
                            player: widget.player,
                            category: category,
                            level: level,
                          ),
                        ),
                      );
                      await load();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
              value: completed / 10,
              color: const Color(0xFFA78BFA),
              backgroundColor: Colors.white12,
            ),
            const SizedBox(height: 5),
            Text(
              '$completed من 10',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    ),
  );
}
