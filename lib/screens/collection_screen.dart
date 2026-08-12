import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/learning_support_service.dart';

class CollectionScreen extends StatelessWidget {
  final Player player;
  const CollectionScreen({super.key, required this.player});

  static const cards = {
    'fox': ('🦊', 'الثعلب', 'يستخدم ذيله للتوازن والدفء.'),
    'planet': ('🪐', 'زحل', 'حوله حلقات من الجليد والصخور.'),
    'owl': ('🦉', 'البومة', 'تستطيع إدارة رأسها بزاوية كبيرة.'),
    'robot': ('🤖', 'الروبوت', 'ينفذ التعليمات المكتوبة في برنامجه.'),
    'dolphin': ('🐬', 'الدلفين', 'يتواصل بأصوات وصفير مميز.'),
    'pyramid': ('🔺', 'الأهرام', 'بناها المصريون القدماء منذ آلاف السنين.'),
    'dragon': ('🐉', 'التنين', 'كائن أسطوري يظهر في قصص شعوب كثيرة.'),
    'telescope': ('🔭', 'التلسكوب', 'يجمع الضوء لنرى الأجسام البعيدة.'),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🃏 ألبوم المعرفة')),
    body: FutureBuilder<Set<String>>(
      future: LearningSupportService.loadCards(player.id),
      builder: (context, snapshot) {
        final owned = snapshot.data ?? <String>{};
        return GridView.builder(
          padding: const EdgeInsets.all(18),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .78,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final entry = cards.entries.elementAt(index);
            final unlocked = owned.contains(entry.key);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unlocked ? entry.value.$1 : '🔒',
                      style: const TextStyle(fontSize: 55),
                    ),
                    Text(
                      unlocked ? entry.value.$2 : 'بطاقة مخفية',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      unlocked
                          ? entry.value.$3
                          : 'أكمل 15 سؤالًا جديدًا لفتح بطاقة.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
