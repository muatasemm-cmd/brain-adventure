import 'package:flutter/material.dart';

import '../widgets/subject_badge.dart';
import 'player_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF58BCE8), Color(0xFF8BE0B1)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .95),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🧠', style: TextStyle(fontSize: 66)),
              ),
              const SizedBox(height: 30),
              const Text(
                'رحلة العباقرة',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 5)],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'تعلّم • فكّر • العب • اكتشف',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 35),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  SubjectBadge(icon: '➗', title: 'رياضيات'),
                  SubjectBadge(icon: '🔬', title: 'علوم'),
                  SubjectBadge(icon: '🌍', title: 'معرفة'),
                  SubjectBadge(icon: '🧩', title: 'منطق'),
                ],
              ),
              const Spacer(flex: 3),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlayerSelectionScreen(),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
                label: const Text(
                  'ابدأ المغامرة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  backgroundColor: const Color(0xFFFFC83D),
                  foregroundColor: const Color(0xFF263238),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '🚀 جاهز لتحدي عقلك؟',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
