import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/adventure_progress.dart';
import '../services/daily_surprise_service.dart';
import '../services/adventure_progress_storage.dart';
import '../services/motivation_service.dart';
import '../services/parent_settings_storage.dart';
import '../services/play_time_service.dart';
import 'genius_room_screen.dart';
import 'settings_screen.dart';
import 'subject_selection_screen.dart';
import 'collection_screen.dart';
import 'review_screen.dart';

class AdventureHomeScreen extends StatefulWidget {
  final Player player;

  const AdventureHomeScreen({super.key, required this.player});

  @override
  State<AdventureHomeScreen> createState() => _AdventureHomeScreenState();
}

class _AdventureHomeScreenState extends State<AdventureHomeScreen> {
  DailySurpriseStatus? surpriseStatus;
  DailyMissionStatus? missions;
  AdventureProgress? progress;
  Timer? timer;
  final sessionStartedAt = DateTime.now();
  bool breakSuggested = false;
  int breakMinutes = 20;
  int dailyLimitMinutes = 60;
  int todaySecondsAtStart = 0;

  @override
  void initState() {
    super.initState();
    refreshSurprise();
    refreshMotivation();
    loadTimeRules();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      refreshSurprise();
      suggestBreakIfNeeded();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    final elapsed = DateTime.now().difference(sessionStartedAt).inSeconds;
    unawaited(
      PlayTimeService.addSession(widget.player.id, DateTime.now(), elapsed),
    );
    super.dispose();
  }

  Future<void> loadTimeRules() async {
    final values = await Future.wait([
      ParentSettingsStorage.loadBreakMinutes(),
      ParentSettingsStorage.loadDailyLimitMinutes(),
      PlayTimeService.loadTodaySeconds(widget.player.id, DateTime.now()),
    ]);
    if (mounted) {
      setState(() {
        breakMinutes = values[0];
        dailyLimitMinutes = values[1];
        todaySecondsAtStart = values[2];
      });
    }
  }

  Future<void> refreshSurprise() async {
    final value = await DailySurpriseService.status(
      playerId: widget.player.id,
      now: DateTime.now(),
    );
    if (mounted) setState(() => surpriseStatus = value);
  }

  Future<void> refreshMotivation() async {
    final values = await Future.wait([
      AdventureProgressStorage.load(widget.player.id),
      MotivationService.loadMissions(widget.player.id, DateTime.now()),
    ]);
    if (mounted) {
      setState(() {
        progress = values[0] as AdventureProgress;
        missions = values[1] as DailyMissionStatus;
      });
    }
  }

  Future<void> suggestBreakIfNeeded() async {
    if (breakSuggested ||
        DateTime.now().difference(sessionStartedAt).inMinutes < breakMinutes) {
      return;
    }
    breakSuggested = true;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🌿 وقت استراحة صغيرة', textAlign: TextAlign.center),
        content: Text(
          'لقد لعبت $breakMinutes دقيقة. قف، حرّك جسمك، واشرب الماء. سننتظرك 💚',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('سآخذ استراحة'),
          ),
        ],
      ),
    );
  }

  bool get dailyLimitReached =>
      todaySecondsAtStart +
          DateTime.now().difference(sessionStartedAt).inSeconds >=
      dailyLimitMinutes * 60;

  Future<void> openMissions() async {
    final value = missions ?? const DailyMissionStatus();
    final claimed = value.complete && !value.claimed
        ? await MotivationService.claimDailyMissions(
            widget.player.id,
            DateTime.now(),
          )
        : false;
    if (claimed) await refreshMotivation();
    if (!mounted) return;
    final latest = missions ?? value;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎯 مهام اليوم',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            _MissionRow(
              label: 'أجب عن 10 أسئلة',
              value: latest.answers,
              target: 10,
            ),
            _MissionRow(
              label: 'العب في مادة واحدة',
              value: latest.subjects.length,
              target: 1,
            ),
            _MissionRow(
              label: '3 إجابات صحيحة من أول محاولة',
              value: latest.correctWithoutMistake,
              target: 3,
            ),
            const SizedBox(height: 12),
            Text(
              latest.claimed
                  ? '✅ استلمت مكافأة اليوم'
                  : latest.complete
                  ? '🎉 تم استلام 60 عملة و5 نجوم!'
                  : '🎁 المكافأة: 60 عملة + 5 نجوم',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String countdown(DateTime next) {
    final difference = next.difference(DateTime.now());
    if (difference.isNegative) return 'جاهز للفتح!';
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return 'يفتح بعد ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> openSurprise() async {
    if (surpriseStatus?.available != true) return;
    final reward = await DailySurpriseService.claim(
      playerId: widget.player.id,
      now: DateTime.now(),
    );
    if (reward == null || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7D6),
        title: const Text('🎉 مفاجأة اليوم! 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.icon, style: const TextStyle(fontSize: 86)),
            const SizedBox(height: 10),
            Text(
              reward.title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'ممتاز! عد غدًا لمفاجأة جديدة.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
    await refreshSurprise();
  }

  @override
  Widget build(BuildContext context) {
    final status = surpriseStatus;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/adventure_home.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .28),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .52),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'أهلًا ${widget.player.name} 👋',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(blurRadius: 9, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text('${widget.player.age} 🎂'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SurpriseBox(
                    available: status?.available == true,
                    label: status == null
                        ? 'جاري التحقق...'
                        : status.available
                        ? 'افتح مفاجأة اليوم!'
                        : countdown(status.nextAvailableAt),
                    onTap: openSurprise,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MotivationChip(
                          icon: '🎯',
                          title: 'مهام اليوم',
                          subtitle: missions == null
                              ? '...'
                              : '${(missions!.answers / 10).clamp(0, 1) * 100 ~/ 1}%',
                          onTap: openMissions,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final pet = MotivationService.petFor(
                              progress ?? const AdventureProgress(),
                            );
                            return _MotivationChip(
                              icon: pet.icon,
                              title: pet.name,
                              subtitle:
                                  'مستوى ${pet.level} • ${pet.progress}/${pet.target}',
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'أكمل الأسئلة ليتطور ${pet.name}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CollectionScreen(player: widget.player),
                            ),
                          ),
                          icon: const Icon(Icons.style_rounded),
                          label: const Text('البطاقات'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: .92,
                            ),
                            foregroundColor: const Color(0xFF243447),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReviewScreen(player: widget.player),
                            ),
                          ),
                          icon: const Icon(Icons.psychology_rounded),
                          label: const Text('المراجعة'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: .92,
                            ),
                            foregroundColor: const Color(0xFF243447),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _MainButton(
                    onTap: () {
                      if (dailyLimitReached) {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'أحسنت لليوم 🌙',
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              'وصلت إلى وقت اللعب اليومي الذي حدده ولي الأمر ($dailyLimitMinutes دقيقة). نكمل المغامرة غدًا!',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('حسنًا'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SubjectSelectionScreen(player: widget.player),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallButton(
                          icon: Icons.home_rounded,
                          label: 'غرفة العبقري',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GeniusRoomScreen(player: widget.player),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SmallButton(
                          icon: Icons.settings_rounded,
                          label: 'الإعدادات',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationChip extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MotivationChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MissionRow extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  const _MissionRow({
    required this.label,
    required this.value,
    required this.target,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${value.clamp(0, target)}/$target  $label',
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: (value / target).clamp(0, 1),
          minHeight: 9,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    ),
  );
}

class _SurpriseBox extends StatelessWidget {
  final bool available;
  final String label;
  final VoidCallback onTap;

  const _SurpriseBox({
    required this.available,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: InkWell(
      onTap: available ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: available
                ? const [Color(0xFFFFD54F), Color(0xFFFF7A18)]
                : const [Color(0xEEFFFFFF), Color(0xDDDDE7F0)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(available ? '🎁' : '🔒', style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'صندوق المفاجآت',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MainButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MainButton({required this.onTap});
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.play_arrow_rounded, size: 38),
    label: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ابدأ التعلم',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        Text('7 مواد • 140 مرحلة • 700 سؤال', textDirection: TextDirection.rtl),
      ],
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB92E),
      foregroundColor: const Color(0xFF243447),
      minimumSize: const Size.fromHeight(78),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 9,
    ),
  );
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      backgroundColor: Colors.white.withValues(alpha: .94),
      foregroundColor: const Color(0xFF243447),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
