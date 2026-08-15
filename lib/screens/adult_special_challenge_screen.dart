import 'dart:async';

import 'package:flutter/material.dart';

import '../models/adult_player.dart';
import '../models/adult_question.dart';
import '../services/adult_storage.dart';
import '../widgets/fireworks_celebration.dart';
import '../widgets/question_report_button.dart';

enum AdultPlayMode { daily, timed, survival, review }

class AdultSpecialChallengeScreen extends StatefulWidget {
  final AdultPlayer player;
  final List<AdultCategory> categories;
  final AdultPlayMode mode;

  const AdultSpecialChallengeScreen({
    super.key,
    required this.player,
    required this.categories,
    required this.mode,
  });

  @override
  State<AdultSpecialChallengeScreen> createState() =>
      _AdultSpecialChallengeScreenState();
}

class _AdultSpecialChallengeScreenState
    extends State<AdultSpecialChallengeScreen> {
  List<AdultQuestion> questions = const [];
  int index = 0;
  int score = 0;
  int lives = 3;
  int seconds = 60;
  String? selected;
  Timer? timer;
  bool loading = true;
  bool finished = false;

  String get title => switch (widget.mode) {
    AdultPlayMode.daily => '☀️ تحدي اليوم',
    AdultPlayMode.timed => '⏱️ تحدي الوقت',
    AdultPlayMode.survival => '❤️ وضع البقاء',
    AdultPlayMode.review => '🔁 المراجعة الذكية',
  };

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    final all = widget.categories.expand((item) => item.questions).toList();
    if (widget.mode == AdultPlayMode.review) {
      final mistakes = await AdultStorage.loadMistakes(widget.player.id);
      questions = all
          .where((item) => mistakes.contains(item.id))
          .take(20)
          .toList();
    } else if (widget.mode == AdultPlayMode.daily) {
      final day = DateTime.now().difference(DateTime(2026)).inDays;
      questions = [
        for (var i = 0; i < widget.categories.length; i++)
          widget.categories[i].questions[(day + i * 7) %
              widget.categories[i].questions.length],
      ];
    } else {
      final seed = DateTime.now().millisecondsSinceEpoch ~/ 3600000;
      questions = List.generate(20, (i) => all[(seed + i * 37) % all.length]);
    }
    if (widget.mode == AdultPlayMode.timed) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || finished) return;
        if (seconds <= 1) {
          setState(() => seconds = 0);
          finish();
        } else {
          setState(() => seconds--);
        }
      });
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> answer(String option) async {
    if (selected != null || finished) return;
    final question = questions[index];
    final correct = option == question.answer;
    if (correct) {
      await AdultStorage.masterQuestion(widget.player.id, question.id);
    } else {
      await AdultStorage.recordMistake(widget.player.id, question.id);
    }
    if (!mounted) return;
    setState(() {
      selected = option;
      if (correct) score++;
      if (!correct && widget.mode == AdultPlayMode.survival) lives--;
    });
  }

  Future<void> next() async {
    if (widget.mode == AdultPlayMode.survival && lives <= 0) {
      await finish();
    } else if (index >= questions.length - 1) {
      await finish();
    } else {
      setState(() {
        index++;
        selected = null;
      });
    }
  }

  Future<void> finish() async {
    if (finished || !mounted) return;
    finished = true;
    timer?.cancel();
    var streak = 0;
    if (widget.mode == AdultPlayMode.daily) {
      streak = await AdultStorage.recordDailyResult(
        playerId: widget.player.id,
        now: DateTime.now(),
        score: score,
      );
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Stack(
        children: [
          if (score >= (questions.length / 2))
            const Positioned.fill(
              child: IgnorePointer(child: FireworksCelebration()),
            ),
          Center(
            child: AlertDialog(
              title: Text(
                score >= questions.length / 2 ? '🏆 أحسنت!' : '💪 جولة جيدة',
                textAlign: TextAlign.center,
              ),
              content: Text(
                'أجبت عن $score من ${questions.length} إجابة صحيحة'
                '${streak > 0 ? '\n🔥 سلسلة الأيام: $streak' : ''}',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('العودة'),
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
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(title),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'لا توجد أسئلة للمراجعة الآن 🎉\nأخطاؤك القادمة ستظهر هنا.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      );
    }
    final question = questions[index];
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          if (widget.mode == AdultPlayMode.timed)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$seconds ث',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (widget.mode == AdultPlayMode.survival)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('❤️ $lives'),
              ),
            ),
        ],
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
                                    ? () => answer(option)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor: selected == null
                                      ? const Color(0xFF334155)
                                      : option == question.answer
                                      ? const Color(0xFF16A34A)
                                      : option == selected
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF334155),
                                  disabledBackgroundColor:
                                      option == question.answer
                                      ? const Color(0xFF16A34A)
                                      : option == selected
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
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
                if (selected != null) ...[
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: next,
                    child: Text(
                      index == questions.length - 1 || lives <= 0
                          ? 'عرض النتيجة'
                          : 'السؤال التالي',
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
}
