import 'package:flutter/material.dart';

import '../data/adult_challenge_data.dart';
import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import 'adult_dashboard_screen.dart';
import '../widgets/question_report_button.dart';

class AdultPlacementScreen extends StatefulWidget {
  final AdultPlayer player;

  const AdultPlacementScreen({super.key, required this.player});

  @override
  State<AdultPlacementScreen> createState() => _AdultPlacementScreenState();
}

class _AdultPlacementScreenState extends State<AdultPlacementScreen> {
  late final List<AdultQuestion> questions;
  int index = 0;
  int score = 0;
  String? selected;

  @override
  void initState() {
    super.initState();
    final categories = buildAdultCategories();
    questions = adultPlacementQuestions(categories);
  }

  Future<void> next() async {
    if (index < questions.length - 1) {
      setState(() {
        index++;
        selected = null;
      });
      return;
    }
    final startLevel = score >= 13
        ? 8
        : score >= 9
        ? 5
        : score >= 5
        ? 3
        : 1;
    await AdultStorage.savePlacement(widget.player.id, startLevel);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اكتمل تحديد المستوى', textAlign: TextAlign.center),
        content: Text(
          'نتيجتك $score من 15\nنقطة البداية المناسبة: المرحلة $startLevel',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 19, height: 1.6),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ابدأ التحدي'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdultDashboardScreen(player: widget.player),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[index];
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('اختبار تحديد المستوى'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                LinearProgressIndicator(
                  value: (index + 1) / questions.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 24),
                Card(
                  color: const Color(0xFF1E293B),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          question.question,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        QuestionReportButton(
                          playerId: widget.player.id,
                          question: question,
                        ),
                        const SizedBox(height: 20),
                        for (final option in question.options)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: selected == null
                                    ? () => setState(() {
                                        selected = option;
                                        if (option == question.answer) score++;
                                      })
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor: const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  option,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (selected != null)
                  FilledButton(
                    onPressed: next,
                    child: Text(index == 14 ? 'عرض المستوى' : 'السؤال التالي'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
