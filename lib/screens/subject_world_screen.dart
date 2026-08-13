import 'package:flutter/material.dart';

import '../data/subject_stage_data.dart';
import '../models/adventure_progress.dart';
import '../models/forest_stage.dart';
import '../models/learning_challenge.dart';
import '../models/player.dart';
import '../models/subject_adventure.dart';
import '../services/adventure_progress_storage.dart';
import '../services/motivation_service.dart';
import '../services/learning_support_service.dart';
import 'forest_stage_screen.dart';

class SubjectWorldScreen extends StatefulWidget {
  final Player player;
  final SubjectAdventure adventure;

  const SubjectWorldScreen({
    super.key,
    required this.player,
    required this.adventure,
  });

  @override
  State<SubjectWorldScreen> createState() => _SubjectWorldScreenState();
}

class _SubjectWorldScreenState extends State<SubjectWorldScreen> {
  AdventureProgress? progress;
  List<ForestStage> stages = const [];

  @override
  void initState() {
    super.initState();
    loadWorld();
  }

  Future<void> loadWorld() async {
    final level =
        await LearningSupportService.loadPlacementLevel(
          widget.player.id,
          widget.adventure.subject.name,
        ) ??
        2;
    final adjustedAge = (widget.player.age + (level - 2) * 2).clamp(5, 14);
    stages = subjectStagesFor(adventure: widget.adventure, age: adjustedAge);
    await loadProgress();
  }

  Future<void> loadProgress() async {
    final value = await AdventureProgressStorage.load(widget.player.id);
    if (mounted) setState(() => progress = value);
  }

  bool stageComplete(ForestStage stage) => stage.challenges.every(
    (challenge) => progress!.completedChallenges.contains(challenge.id),
  );

  int get unlockedStage {
    if (progress == null) return 1;
    var unlocked = 1;
    for (final stage in stages) {
      if (!stageComplete(stage)) break;
      unlocked = (stage.number + 1).clamp(1, 20);
    }
    return unlocked;
  }

  int completedCount(ForestStage stage) => stage.challenges
      .where((item) => progress!.completedChallenges.contains(item.id))
      .length;

  Future<void> openStage(ForestStage stage) async {
    if (stage.number > unlockedStage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'أكمل المرحلة السابقة أولًا',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ForestStageScreen(player: widget.player, stage: stage),
      ),
    );
    await loadProgress();
    if (mounted && stageComplete(stage)) {
      await _showStoryAndReward(stage);
    }
  }

  String storyFor(int stage) {
    final chapter = ((stage - 1) ~/ 5) + 1;
    final stories = switch (widget.adventure.subject) {
      LearningSubject.math => [
        'وجدت بوابة الأرقام وأعدت النظام للقرية.',
        'عبرت جسر الضرب وأنرت فوانيسه.',
        'فككت شفرة قلعة الحساب.',
        'هزمت ملك الفوضى وأصبحت بطل الأرقام!',
      ],
      LearningSubject.science => [
        'أنقذت حديقة النباتات وأعدت الماء للجذور.',
        'أعدت الطاقة إلى مختبر الكائنات.',
        'اكتشفت سر الكواكب وفتحت المرصد.',
        'هزمت روبوت الفوضى وأصبحت عالمًا صغيرًا!',
      ],
      LearningSubject.culture => [
        'جمعت أول صفحات كتاب العالم.',
        'عبرت القارات ووضعت المدن على الخريطة.',
        'أعدت قصص الشعوب إلى مكتبة الحكمة.',
        'أكملت كتاب العالم وأصبحت مستكشفًا عظيمًا!',
      ],
      LearningSubject.logic => [
        'فتحت أول أبواب المتاهة.',
        'حللت الأنماط وأعدت ترتيب الطرق.',
        'فككت شفرة البرج الغامض.',
        'هزمت سيد الألغاز وأصبحت محقق المنطق!',
      ],
      LearningSubject.arabic => [
        'جمعت الحروف لتفتح بوابة الكلمات الجميلة.',
        'أعدت الجمل الضائعة إلى مكتبة اللغة.',
        'حللت أسرار النحو وصرت فارس الحروف.',
        'أنقذت مملكة العربية وأصبحت بطل البيان!',
      ],
      LearningSubject.history => [
        'عثرت على أول أثر في رحلة الزمن.',
        'فتحت بوابة الحضارات القديمة.',
        'حفظت كنوز الماضي في متحف الأبطال.',
        'أكملت سجل الزمن وأصبحت مؤرخًا صغيرًا!',
      ],
      LearningSubject.geography => [
        'رسمت أول طريق على خريطة العالم.',
        'عبرت القارات واكتشفت البحار.',
        'أعدت أسماء المدن إلى الخريطة السحرية.',
        'أكملت أطلس العالم وأصبحت مستكشفًا عظيمًا!',
      ],
      LearningSubject.mixed => const ['', '', '', ''],
    };
    return stories[chapter - 1];
  }

  Future<void> _showStoryAndReward(ForestStage stage) async {
    if (!const [5, 10, 15, 20].contains(stage.number)) return;
    final reward = MotivationService.milestones.firstWhere(
      (item) => item.stage == stage.number,
    );
    final claimed = await MotivationService.claimMilestone(
      playerId: widget.player.id,
      subject: widget.adventure.subject,
      stage: stage.number,
    );
    if (claimed == null || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${reward.icon} صندوق ${reward.tier}',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              storyFor(stage.number),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 14),
            Text(
              '🪙 +${reward.coins}   ⭐ +${reward.stars}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            if (stage.number == 20) ...[
              const Divider(height: 26),
              Text(
                '🎓 شهادة ${widget.adventure.title} للبطل ${widget.player.name}',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('استمر'),
          ),
        ],
      ),
    );
    await loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final value = progress;
    final color = Color(widget.adventure.colorValue);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.adventure.backgroundAsset, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: .18)),
          SafeArea(
            child: value == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${widget.adventure.icon} ${widget.adventure.title}',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'المرحلة $unlockedStage من 20',
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                            Text('⭐ ${value.stars}'),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(34, 8, 34, 32),
                          itemCount: stages.length,
                          itemBuilder: (context, index) {
                            final stage = stages[index];
                            final unlocked = stage.number <= unlockedStage;
                            final completed = completedCount(stage);
                            final alignLeft = index.isEven;
                            return Align(
                              alignment: alignLeft
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: InkWell(
                                onTap: () => openStage(stage),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 190,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: unlocked
                                        ? Colors.white.withValues(alpha: .95)
                                        : Colors.grey.shade300.withValues(
                                            alpha: .9,
                                          ),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: unlocked ? color : Colors.grey,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: unlocked
                                            ? color
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                        child: Text(
                                          unlocked ? '${stage.number}' : '🔒',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              stage.name,
                                              textDirection: TextDirection.rtl,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              '$completed/5  ${'⭐' * completed}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
