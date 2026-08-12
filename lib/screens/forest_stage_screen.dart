import 'dart:async';

import 'package:flutter/material.dart';

import '../games/matching_game.dart';
import '../games/memory_game.dart';
import '../games/ordering_game.dart';
import '../models/forest_stage.dart';
import '../models/adventure_progress.dart';
import '../models/learning_challenge.dart';
import '../models/player.dart';
import '../services/adventure_progress_storage.dart';
import '../services/adaptive_difficulty_service.dart';
import '../services/settings_storage.dart';
import '../services/motivation_service.dart';
import '../services/learning_support_service.dart';
import '../services/narrator_service.dart';

class ForestStageScreen extends StatefulWidget {
  final Player player;
  final ForestStage stage;

  const ForestStageScreen({
    super.key,
    required this.player,
    required this.stage,
  });

  @override
  State<ForestStageScreen> createState() => _ForestStageScreenState();
}

class _ForestStageScreenState extends State<ForestStageScreen> {
  final numberController = TextEditingController();
  int challengeIndex = 0;
  int hintIndex = 0;
  int correctCount = 0;
  bool answeredCorrectly = false;
  bool saving = false;
  String? feedback;
  final startedAt = DateTime.now();
  bool initializing = true;
  AdventureProgress? savedProgress;
  bool madeMistakeOnChallenge = false;

  LearningChallenge get challenge => widget.stage.challenges[challengeIndex];

  @override
  void initState() {
    super.initState();
    resumeProgress();
  }

  Future<void> resumeProgress() async {
    final progress = await AdventureProgressStorage.load(widget.player.id);
    var resumeAt = widget.stage.challenges.indexWhere(
      (item) => !progress.completedChallenges.contains(item.id),
    );
    if (resumeAt < 0) resumeAt = 0;
    if (mounted) {
      setState(() {
        savedProgress = progress;
        challengeIndex = resumeAt;
        initializing = false;
      });
    }
  }

  @override
  void dispose() {
    unawaited(NarratorService.stop());
    unawaited(
      AdventureProgressStorage.addPlayTime(
        widget.player.id,
        DateTime.now().difference(startedAt),
      ),
    );
    numberController.dispose();
    super.dispose();
  }

  String normalizeNumber(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const latin = '0123456789';
    var normalized = value.trim();
    for (var index = 0; index < arabic.length; index++) {
      normalized = normalized.replaceAll(arabic[index], latin[index]);
    }
    return normalized;
  }

  Future<void> submit(String answer) async {
    if (saving || answeredCorrectly || answer.trim().isEmpty) return;
    final isCorrect =
        normalizeNumber(answer) == normalizeNumber(challenge.correctAnswer);
    setState(() => saving = true);
    await AdventureProgressStorage.recordAnswer(
      playerId: widget.player.id,
      challenge: challenge,
      correct: isCorrect,
      stageNumber: widget.stage.number,
      stageCompleted:
          isCorrect && challengeIndex == widget.stage.challenges.length - 1,
    );
    if (isCorrect) {
      await MotivationService.recordCorrectAnswer(
        playerId: widget.player.id,
        subject: challenge.subject,
        now: DateTime.now(),
        firstTry: !madeMistakeOnChallenge,
      );
      final currentProgress = await AdventureProgressStorage.load(
        widget.player.id,
      );
      await LearningSupportService.unlockCardForProgress(
        widget.player.id,
        currentProgress.completedChallenges.length,
      );
      await SettingsStorage.successFeedback();
    } else {
      madeMistakeOnChallenge = true;
      await LearningSupportService.recordMistake(widget.player.id, challenge);
      await SettingsStorage.errorFeedback();
    }
    if (!mounted) return;
    setState(() {
      saving = false;
      if (isCorrect) {
        answeredCorrectly = true;
        correctCount++;
        feedback = 'رائع! ${challenge.explanation}';
      } else {
        final visibleHint =
            challenge.hints[hintIndex.clamp(0, challenge.hints.length - 1)];
        feedback = 'قريب جدًا، حاول مرة أخرى.\n💡 $visibleHint';
        if (hintIndex < challenge.hints.length - 1) hintIndex++;
      }
    });
  }

  void next() {
    if (challengeIndex == widget.stage.challenges.length - 1) {
      showCompletion();
      return;
    }
    setState(() {
      challengeIndex++;
      hintIndex = 0;
      answeredCorrectly = false;
      feedback = null;
      numberController.clear();
      madeMistakeOnChallenge = false;
    });
  }

  Future<void> showCompletion() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          widget.stage.number == 20
              ? '👑 هزمت زعيم المادة!'
              : '🎉 اكتملت ${widget.stage.name}',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'أكملت $correctCount تحديات\n'
          '⭐ +$correctCount نجوم   🪙 +${correctCount * 10}\n'
          '💎 حصلت على بلورة المرحلة',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 18, height: 1.7),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('العودة إلى الخريطة'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  String subjectLabel(LearningSubject subject) => switch (subject) {
    LearningSubject.math => '🧮 رياضيات',
    LearningSubject.science => '🔬 علوم',
    LearningSubject.culture => '🌍 معرفة',
    LearningSubject.logic => '🧠 منطق',
    LearningSubject.mixed => '🏆 التحدي النهائي',
  };

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final progress = (challengeIndex + 1) / widget.stage.challenges.length;
    final adaptive = AdaptiveDifficultyService.evaluate(
      age: widget.player.age,
      subject: challenge.subject,
      progress: savedProgress ?? const AdventureProgress(),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text('${widget.stage.icon} ${widget.stage.name}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFFFC83D),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              'التحدي ${challengeIndex + 1} من ${widget.stage.challenges.length}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      subjectLabel(challenge.subject),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      avatar: const Icon(Icons.auto_awesome, size: 18),
                      label: Text(adaptive.label),
                      backgroundColor: const Color(0xFFE0F2FE),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.title,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      challenge.question,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 22, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => NarratorService.speak(
                        '${challenge.title}. ${challenge.question}. ${challenge.options.join('. ')}',
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('اسمع السؤال'),
                    ),
                    if (adaptive.shouldShowEarlyHint(challenge.difficulty)) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7D6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '💡 ${challenge.hints.first}',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    if (challenge.type == ChallengeType.ordering)
                      OrderingGame(
                        key: ValueKey(challenge.id),
                        items: challenge.options,
                        enabled: !answeredCorrectly && !saving,
                        onSubmit: submit,
                      )
                    else if (challenge.type == ChallengeType.matching)
                      MatchingGame(
                        key: ValueKey(challenge.id),
                        encodedPairs: challenge.options,
                        enabled: !answeredCorrectly && !saving,
                        onComplete: () => submit(challenge.correctAnswer),
                        onWrong: () => submit('__wrong__'),
                      )
                    else if (challenge.type == ChallengeType.memory)
                      MemoryGame(
                        key: ValueKey(challenge.id),
                        symbols: challenge.options,
                        enabled: !answeredCorrectly && !saving,
                        onComplete: () => submit(challenge.correctAnswer),
                        onWrong: () => submit('__wrong__'),
                      )
                    else if (challenge.type == ChallengeType.numberInput)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: numberController,
                              enabled: !answeredCorrectly,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'اكتب الإجابة',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: submit,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: answeredCorrectly
                                ? null
                                : () => submit(numberController.text),
                            child: const Text('تحقق'),
                          ),
                        ],
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: challenge.options.length,
                        itemBuilder: (context, index) {
                          final option = challenge.options[index];
                          final correct =
                              answeredCorrectly &&
                              option == challenge.correctAnswer;
                          return ElevatedButton(
                            onPressed: answeredCorrectly
                                ? null
                                : () => submit(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: correct
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF263238),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              option,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (saving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (feedback != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: answeredCorrectly
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  feedback!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 17, height: 1.5),
                ),
              ),
            if (answeredCorrectly)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    challengeIndex == widget.stage.challenges.length - 1
                        ? 'استلام المكافأة'
                        : 'التحدي التالي',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFFFFC83D),
                    foregroundColor: const Color(0xFF263238),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
