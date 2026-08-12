import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/learning_support_service.dart';
import 'adventure_home_screen.dart';

class PlacementTestScreen extends StatefulWidget {
  final Player player;
  const PlacementTestScreen({super.key, required this.player});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  int index = 0;
  final scores = <String, int>{
    'math': 0,
    'science': 0,
    'culture': 0,
    'logic': 0,
  };

  final questions = <(String, String, List<String>, String)>[
    ('math', 'ما ناتج 7 + 5؟', ['10', '12', '14'], '12'),
    ('science', 'أي عضو يضخ الدم؟', ['القلب', 'المعدة', 'الرئة'], 'القلب'),
    ('logic', 'ما العدد التالي: 2، 4، 6، ...؟', ['7', '8', '10'], '8'),
    (
      'culture',
      'في أي قارة تقع فلسطين؟',
      ['آسيا', 'أوروبا', 'أفريقيا'],
      'آسيا',
    ),
    ('math', 'ما ناتج 6 × 4؟', ['20', '24', '28'], '24'),
    (
      'science',
      'ما القوة التي تجذبنا للأرض؟',
      ['الجاذبية', 'الضوء', 'الحرارة'],
      'الجاذبية',
    ),
    ('culture', 'ما عاصمة مصر؟', ['القاهرة', 'عمّان', 'الرياض'], 'القاهرة'),
    ('logic', 'أيها مختلف؟', ['🍎', '🍌', '🚗'], '🚗'),
  ];

  Future<void> answer(String value) async {
    final question = questions[index];
    if (value == question.$4) scores[question.$1] = scores[question.$1]! + 1;
    if (index < questions.length - 1) {
      setState(() => index++);
      return;
    }
    await saveLevels();
  }

  Future<void> saveLevels({bool balanced = false}) async {
    for (final entry in scores.entries) {
      final level = balanced
          ? 2
          : entry.value == 0
          ? 1
          : entry.value == 1
          ? 2
          : 3;
      await LearningSupportService.savePlacementLevel(
        widget.player.id,
        level,
        entry.key,
      );
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdventureHomeScreen(player: widget.player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 اكتشف مستواك'),
        actions: [
          TextButton(
            onPressed: () => saveLevels(balanced: true),
            child: const Text('تخطٍّ'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (index + 1) / questions.length,
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            ),
            const Spacer(),
            Text(
              'السؤال ${index + 1} من ${questions.length}',
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 18),
            Text(
              question.$2,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 26),
            for (final option in question.$3)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => answer(option),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 20)),
                ),
              ),
            const Spacer(),
            const Text(
              'نحدد مستوى مستقلًا لكل مادة 💚',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
