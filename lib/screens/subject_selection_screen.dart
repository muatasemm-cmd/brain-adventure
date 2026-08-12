import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/subject_adventure.dart';
import 'subject_world_screen.dart';

class SubjectSelectionScreen extends StatelessWidget {
  final Player player;

  const SubjectSelectionScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/subjects_hero.png', fit: BoxFit.cover),
        Container(color: const Color(0xFF0F3550).withValues(alpha: .42)),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'اختر مادتك يا ${player.name}',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Text(
                'كل مادة فيها 20 مرحلة',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .93),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemCount: subjectAdventures.length,
                  itemBuilder: (context, index) {
                    final subject = subjectAdventures[index];
                    final color = Color(subject.colorValue);
                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectWorldScreen(
                            player: player,
                            adventure: subject,
                          ),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subject.icon,
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subject.title,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subject.description,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
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
