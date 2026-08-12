import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/learning_support_service.dart';

class ReviewScreen extends StatefulWidget {
  final Player player;
  const ReviewScreen({super.key, required this.player});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Future<List<ReviewEntry>> future;
  @override
  void initState() {
    super.initState();
    future = LearningSupportService.loadReview(widget.player.id);
  }

  Future<void> answer(ReviewEntry entry, String answer) async {
    final correct = answer.trim() == entry.answer.trim();
    final mastered = await LearningSupportService.recordReviewAnswer(
      widget.player.id,
      entry.challengeId,
      correct,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mastered
              ? 'أحسنت! أتقنت هذه المهارة 🎉'
              : correct
              ? 'إجابة صحيحة! أجب مرة أخرى لاحقًا لتتقنها ⭐'
              : 'حاول مرة أخرى؛ الإتقان يحتاج إجابتين صحيحتين متتاليتين.',
        ),
      ),
    );
    setState(
      () => future = LearningSupportService.loadReview(widget.player.id),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🧠 المراجعة الذكية')),
    body: FutureBuilder<List<ReviewEntry>>(
      future: future,
      builder: (context, snapshot) {
        final entries = snapshot.data;
        if (entries == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (entries.isEmpty) {
          return const Center(
            child: Text(
              '🎉 لا توجد مهارات تحتاج مراجعة',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              child: ExpansionTile(
                title: Text(entry.question, textDirection: TextDirection.rtl),
                subtitle: Text(
                  'تمت مراجعتها ${entry.mistakes} مرة',
                  textDirection: TextDirection.rtl,
                ),
                childrenPadding: const EdgeInsets.all(14),
                children: [
                  Text(
                    'تقدم الإتقان: ${entry.masteryCorrect}/2',
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in entry.options)
                        ElevatedButton(
                          onPressed: () => answer(entry, option),
                          child: Text(option),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
