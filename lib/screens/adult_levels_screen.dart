import 'package:flutter/material.dart';

import '../data/adult_challenge_data.dart';
import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import '../services/adult_progress_rules.dart';
import 'adult_quiz_screen.dart';

class AdultLevelsScreen extends StatefulWidget {
  final AdultPlayer player;
  final AdultCategory category;

  const AdultLevelsScreen({
    super.key,
    required this.player,
    required this.category,
  });

  @override
  State<AdultLevelsScreen> createState() => _AdultLevelsScreenState();
}

class _AdultLevelsScreenState extends State<AdultLevelsScreen> {
  Map<String, int> progress = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    progress = await AdultStorage.loadProgress(widget.player.id);
    if (mounted) setState(() => loading = false);
  }

  bool isCompleted(int level) =>
      AdultProgressRules.isLevelCompleted(progress, widget.category.id, level);

  bool isUnlocked(int level) =>
      AdultProgressRules.isLevelUnlocked(progress, widget.category.id, level);

  Future<void> openLevel(int level) async {
    if (!isUnlocked(level)) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdultQuizScreen(
          player: widget.player,
          category: widget.category,
          level: level,
        ),
      ),
    );
    await load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text('${widget.category.icon} ${widget.category.name}'),
      centerTitle: true,
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 128,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: adultLevelCount,
            itemBuilder: (context, index) {
              final level = index + 1;
              final completed = isCompleted(level);
              final unlocked = isUnlocked(level);
              final score = progress['${widget.category.id}:$level'];
              return Card(
                color: unlocked
                    ? const Color(0xFF334155)
                    : const Color(0xFF1E293B),
                child: InkWell(
                  onTap: unlocked ? () => openLevel(level) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          completed
                              ? Icons.workspace_premium_rounded
                              : unlocked
                              ? Icons.play_circle_fill_rounded
                              : Icons.lock_rounded,
                          color: completed
                              ? const Color(0xFFFBBF24)
                              : unlocked
                              ? const Color(0xFFA78BFA)
                              : Colors.white30,
                          size: 34,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'المرحلة $level',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: unlocked ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          completed
                              ? 'أفضل نتيجة $score/5'
                              : unlocked
                              ? '5 أسئلة'
                              : 'أكمل السابقة أولًا',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: unlocked ? Colors.white60 : Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
  );
}
