import 'package:flutter/material.dart';

import '../models/adult_player.dart';
import '../services/adult_storage.dart';

class AdultInsightsScreen extends StatefulWidget {
  final AdultPlayer player;

  const AdultInsightsScreen({super.key, required this.player});

  @override
  State<AdultInsightsScreen> createState() => _AdultInsightsScreenState();
}

class _AdultInsightsScreenState extends State<AdultInsightsScreen> {
  Map<String, int> progress = {};
  Map<String, dynamic> daily = {};
  Set<String> mistakes = {};
  List<Map<String, dynamic>> reports = [];
  int placement = 1;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final results = await Future.wait([
      AdultStorage.loadProgress(widget.player.id),
      AdultStorage.loadDaily(widget.player.id),
      AdultStorage.loadMistakes(widget.player.id),
      AdultStorage.loadReports(widget.player.id),
      AdultStorage.loadPlacement(widget.player.id),
    ]);
    progress = results[0] as Map<String, int>;
    daily = results[1] as Map<String, dynamic>;
    mistakes = results[2] as Set<String>;
    reports = results[3] as List<Map<String, dynamic>>;
    placement = results[4] as int? ?? 1;
    if (mounted) setState(() => loading = false);
  }

  String get recommendation {
    if (mistakes.length >= 10) {
      return 'ابدأ بالمراجعة الذكية؛ لديك ${mistakes.length} أسئلة تحتاج تثبيتًا.';
    }
    if ((daily['streak'] as int? ?? 0) < 3) {
      return 'جرّب تحدي اليوم ثلاثة أيام متتالية لبناء عادة قوية.';
    }
    if (progress.length < 10) {
      return 'ركز على مجال واحد حتى تكمل أول عشر مراحل.';
    }
    return 'أداؤك ممتاز؛ جرّب تحدي الوقت أو وضع البقاء لرفع سرعتك.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: const Text('الإنجازات والملاحظات'),
      centerTitle: true,
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: const Color(0xFF312E81),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Text('🧙‍♂️', style: TextStyle(fontSize: 48)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'مرشد العباقرة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              recommendation,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'مستوى البداية: المرحلة $placement',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Badge(
                    icon: '⭐',
                    title: 'أول خطوة',
                    unlocked: progress.isNotEmpty,
                  ),
                  _Badge(
                    icon: '🏅',
                    title: '10 مراحل',
                    unlocked: progress.length >= 10,
                  ),
                  _Badge(
                    icon: '🏆',
                    title: '50 مرحلة',
                    unlocked: progress.length >= 50,
                  ),
                  _Badge(
                    icon: '🔥',
                    title: '3 أيام',
                    unlocked: (daily['streak'] as int? ?? 0) >= 3,
                  ),
                  _Badge(
                    icon: '💎',
                    title: '7 أيام',
                    unlocked: (daily['streak'] as int? ?? 0) >= 7,
                  ),
                  _Badge(
                    icon: '🧠',
                    title: 'مراجعة مكتملة',
                    unlocked: progress.isNotEmpty && mistakes.isEmpty,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Expanded(
                    child: Text(
                      'بلاغات الأسئلة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (reports.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await AdultStorage.clearReports(widget.player.id);
                        await load();
                      },
                      child: const Text('مسح الكل'),
                    ),
                ],
              ),
              if (reports.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'لا توجد بلاغات محفوظة.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final report in reports.reversed)
                  Card(
                    color: const Color(0xFF1E293B),
                    child: ListTile(
                      leading: const Icon(
                        Icons.flag_outlined,
                        color: Color(0xFFFBBF24),
                      ),
                      title: Text(
                        report['reason'] as String,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${report['questionId']}\n${report['question']}',
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
            ],
          ),
  );
}

class _Badge extends StatelessWidget {
  final String icon;
  final String title;
  final bool unlocked;
  const _Badge({
    required this.icon,
    required this.title,
    required this.unlocked,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 145,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: unlocked ? const Color(0xFFFDE68A) : const Color(0xFF334155),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Text(unlocked ? icon : '🔒', style: const TextStyle(fontSize: 30)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: unlocked ? const Color(0xFF422006) : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
