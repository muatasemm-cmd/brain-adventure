import 'package:flutter/material.dart';

import '../models/adventure_progress.dart';
import '../models/player.dart';
import '../services/adventure_progress_storage.dart';
import '../services/parent_settings_storage.dart';
import '../services/player_storage.dart';
import '../services/play_time_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  static Future<void> open(BuildContext context) async {
    final storedPin = await ParentSettingsStorage.loadPin();
    if (!context.mounted) return;
    final pinController = TextEditingController();
    String? error;
    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            storedPin == null ? 'إنشاء رمز ولي الأمر' : 'منطقة ولي الأمر',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                storedPin == null
                    ? 'اختر رمزًا من 4 أرقام لحماية التقارير.'
                    : 'أدخل الرمز المكوّن من 4 أرقام.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'رمز PIN',
                  errorText: error,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final entered = pinController.text;
                if (!RegExp(r'^\d{4}$').hasMatch(entered)) {
                  setDialogState(() => error = 'أدخل أربعة أرقام');
                  return;
                }
                if (storedPin != null && entered != storedPin) {
                  setDialogState(() => error = 'الرمز غير صحيح');
                  return;
                }
                if (storedPin == null) {
                  await ParentSettingsStorage.savePin(entered);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: Text(storedPin == null ? 'حفظ وفتح' : 'فتح'),
            ),
          ],
        ),
      ),
    );
    // Let the dialog route finish its reverse animation before disposing its
    // text controller or pushing the dashboard route.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    pinController.dispose();
    if (allowed == true && context.mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      );
    }
  }

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late Future<List<(Player, AdventureProgress, int)>> reports;
  int surpriseHour = 20;
  int breakMinutes = 20;
  int dailyLimitMinutes = 60;

  @override
  void initState() {
    super.initState();
    reports = loadReports();
    loadSurpriseHour();
    loadTimeRules();
  }

  Future<void> loadTimeRules() async {
    final values = await Future.wait([
      ParentSettingsStorage.loadBreakMinutes(),
      ParentSettingsStorage.loadDailyLimitMinutes(),
    ]);
    if (mounted) {
      setState(() {
        breakMinutes = values[0];
        dailyLimitMinutes = values[1];
      });
    }
  }

  Future<void> loadSurpriseHour() async {
    final value = await ParentSettingsStorage.loadSurpriseHour();
    if (mounted) setState(() => surpriseHour = value);
  }

  Future<void> chooseSurpriseHour() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: surpriseHour, minute: 0),
      helpText: 'وقت صندوق المفاجآت',
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
    );
    if (selected == null) return;
    await ParentSettingsStorage.saveSurpriseHour(selected.hour);
    if (mounted) setState(() => surpriseHour = selected.hour);
  }

  String hourLabel(int hour) {
    final normalized = hour % 12 == 0 ? 12 : hour % 12;
    return '$normalized:00 ${hour >= 12 ? 'مساءً' : 'صباحًا'}';
  }

  Future<List<(Player, AdventureProgress, int)>> loadReports() async {
    final players = await PlayerStorage.loadPlayers();
    return Future.wait(
      players.map((player) async {
        final progress = await AdventureProgressStorage.load(player.id);
        final todaySeconds = await PlayTimeService.loadTodaySeconds(
          player.id,
          DateTime.now(),
        );
        return (player, progress, todaySeconds);
      }),
    );
  }

  String durationLabel(int seconds) {
    if (seconds < 60) return '$seconds ثانية';
    final minutes = seconds ~/ 60;
    return '$minutes دقيقة';
  }

  String subjectLabel(String subject) => switch (subject) {
    'math' => 'الرياضيات',
    'science' => 'العلوم',
    'culture' => 'المعرفة',
    'logic' => 'المنطق',
    'mixed' => 'التحديات المختلطة',
    _ => subject,
  };

  String recommendation(AdventureProgress progress) {
    if (progress.attemptsBySubject.isEmpty) {
      return 'ابدأوا أول محطة في الغابة لتظهر توصيات التعلم.';
    }
    final rates = progress.attemptsBySubject.entries.map((entry) {
      final correct = progress.correctBySubject[entry.key] ?? 0;
      return MapEntry(entry.key, correct / entry.value);
    }).toList()..sort((a, b) => a.value.compareTo(b.value));
    final weakest = rates.first;
    final strongest = rates.last;
    return 'تقدم جميل في ${subjectLabel(strongest.key)}، '
        'وننصح هذا الأسبوع بمزيد من ألعاب ${subjectLabel(weakest.key)}.';
  }

  Future<void> changePin() async {
    final controller = TextEditingController();
    String? error;
    final newPin = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تغيير رمز PIN', textAlign: TextAlign.center),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'الرمز الجديد',
              errorText: error,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!RegExp(r'^\d{4}$').hasMatch(controller.text)) {
                  setDialogState(() => error = 'أدخل أربعة أرقام');
                  return;
                }
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    controller.dispose();
    if (newPin == null) return;
    await ParentSettingsStorage.savePin(newPin);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تغيير رمز ولي الأمر')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍👩‍👧‍👦 منطقة ولي الأمر'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'تغيير رمز PIN',
            onPressed: changePin,
            icon: const Icon(Icons.lock_reset_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<(Player, AdventureProgress, int)>>(
        future: reports,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: ListTile(
                  leading: const Text('🎁', style: TextStyle(fontSize: 32)),
                  title: const Text(
                    'صندوق المفاجآت اليومي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'موعد الفتح: ${hourLabel(surpriseHour)} • يبقى متاحًا حتى نهاية اليوم',
                    textDirection: TextDirection.rtl,
                  ),
                  trailing: const Icon(Icons.schedule_rounded),
                  onTap: chooseSurpriseHour,
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.self_improvement_rounded),
                      title: const Text(
                        'تذكير الاستراحة',
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: DropdownButton<int>(
                        value: breakMinutes,
                        items: [10, 15, 20, 30]
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text('$v دقيقة'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          await ParentSettingsStorage.saveBreakMinutes(v);
                          if (mounted) setState(() => breakMinutes = v);
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.timer_off_rounded),
                      title: const Text(
                        'الحد اليومي للعب',
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: DropdownButton<int>(
                        value: dailyLimitMinutes,
                        items: [30, 45, 60, 90]
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text('$v دقيقة'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          await ParentSettingsStorage.saveDailyLimitMinutes(v);
                          if (mounted) setState(() => dailyLimitMinutes = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ملخص التعلّم المحفوظ على هذا الجهاز',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              for (final report in snapshot.data!)
                _PlayerReportCard(
                  player: report.$1,
                  progress: report.$2,
                  durationLabel: durationLabel,
                  subjectLabel: subjectLabel,
                  recommendation: recommendation(report.$2),
                  todaySeconds: report.$3,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerReportCard extends StatelessWidget {
  final Player player;
  final AdventureProgress progress;
  final String Function(int) durationLabel;
  final String Function(String) subjectLabel;
  final String recommendation;
  final int todaySeconds;

  const _PlayerReportCard({
    required this.player,
    required this.progress,
    required this.durationLabel,
    required this.subjectLabel,
    required this.recommendation,
    required this.todaySeconds,
  });

  @override
  Widget build(BuildContext context) {
    final totalAttempts = progress.attemptsBySubject.values.fold(
      0,
      (a, b) => a + b,
    );
    final totalCorrect = progress.correctBySubject.values.fold(
      0,
      (a, b) => a + b,
    );
    final overall = totalAttempts == 0
        ? 0
        : (totalCorrect * 100 / totalAttempts).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${player.avatar} ${player.name} — ${player.age} سنوات',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(
                  label: 'مدة التعلم',
                  value: durationLabel(progress.totalPlaySeconds),
                ),
                _Metric(label: 'لعب اليوم', value: durationLabel(todaySeconds)),
                _Metric(label: 'المحاولات', value: '$totalAttempts'),
                _Metric(label: 'الإجابات الصحيحة', value: '$totalCorrect'),
                _Metric(label: 'نسبة النجاح', value: '$overall%'),
                _Metric(label: 'النجوم', value: '${progress.stars} ⭐'),
                _Metric(label: 'البلورات', value: '${progress.crystals} 💎'),
              ],
            ),
            const Divider(height: 28),
            const Text(
              'المهارات',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (progress.attemptsBySubject.isEmpty)
              const Text('لا توجد بيانات بعد', textDirection: TextDirection.rtl)
            else
              for (final entry in progress.attemptsBySubject.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 115,
                        child: Text(
                          subjectLabel(entry.key),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value:
                              (progress.correctBySubject[entry.key] ?? 0) /
                              entry.value,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${((progress.correctBySubject[entry.key] ?? 0) * 100 / entry.value).round()}%',
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '💡 $recommendation',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    width: 135,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, textDirection: TextDirection.rtl),
      ],
    ),
  );
}
