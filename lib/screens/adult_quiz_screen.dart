import 'package:flutter/material.dart';

import '../data/adult_challenge_data.dart';
import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import '../services/narrator_service.dart';
import '../widgets/fireworks_celebration.dart';

class AdultQuizScreen extends StatefulWidget {
  final AdultPlayer player;
  final AdultCategory category;
  final int level;

  const AdultQuizScreen({
    super.key,
    required this.player,
    required this.category,
    required this.level,
  });

  @override
  State<AdultQuizScreen> createState() => _AdultQuizScreenState();
}

class _AdultQuizScreenState extends State<AdultQuizScreen> {
  late final List<AdultQuestion> questions;
  int index = 0;
  int score = 0;
  String? selected;

  @override
  void initState() {
    super.initState();
    questions = adultLevelQuestions(widget.category, widget.level);
  }

  AdultQuestion get question => questions[index];

  Future<void> answer(String option) async {
    if (selected != null) return;
    if (option == question.answer) {
      await AdultStorage.masterQuestion(widget.player.id, question.id);
    } else {
      await AdultStorage.recordMistake(widget.player.id, question.id);
    }
    if (!mounted) return;
    setState(() {
      selected = option;
      if (option == question.answer) score++;
    });
  }

  Future<void> next() async {
    if (index < questions.length - 1) {
      setState(() {
        index++;
        selected = null;
      });
      return;
    }
    await AdultStorage.completeLevel(
      playerId: widget.player.id,
      categoryId: widget.category.id,
      level: widget.level,
      score: score,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Stack(
        children: [
          if (score >= 3)
            const Positioned.fill(
              child: IgnorePointer(child: FireworksCelebration()),
            ),
          Center(
            child: AlertDialog(
              title: Text(
                score >= 4
                    ? '🏆 أداء رائع!'
                    : score >= 3
                    ? '👏 أحسنت!'
                    : '💪 حاول مرة أخرى',
                textAlign: TextAlign.center,
              ),
              content: Text(
                'نتيجتك $score من ${questions.length}\n${score * 20} نقطة',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 21, height: 1.6),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('العودة للمستويات'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text('${widget.category.icon} المستوى ${widget.level}'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              LinearProgressIndicator(
                value: (index + 1) / questions.length,
                minHeight: 10,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFA78BFA),
                backgroundColor: Colors.white12,
              ),
              const SizedBox(height: 10),
              Text(
                'السؤال ${index + 1} من ${questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
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
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            NarratorService.speak(question.question),
                        color: Colors.white70,
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                      const SizedBox(height: 16),
                      for (final option in question.options)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selected == null
                                  ? () => answer(option)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(17),
                                backgroundColor: selected == null
                                    ? const Color(0xFF334155)
                                    : option == question.answer
                                    ? const Color(0xFF16A34A)
                                    : option == selected
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF334155),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    option == question.answer
                                    ? const Color(0xFF16A34A)
                                    : option == selected
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF334155),
                                disabledForegroundColor: Colors.white,
                              ),
                              child: Text(
                                option,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (selected != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected == question.answer
                        ? const Color(0xFF14532D)
                        : const Color(0xFF7F1D1D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${selected == question.answer ? 'إجابة صحيحة' : 'الإجابة الصحيحة: ${question.answer}'}\n${question.explanation}',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: next,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(
                    index == questions.length - 1
                        ? 'عرض النتيجة'
                        : 'السؤال التالي',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
