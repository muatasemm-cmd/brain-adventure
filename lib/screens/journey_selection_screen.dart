import 'package:flutter/material.dart';

import 'adult_player_screen.dart';
import 'player_selection_screen.dart';

class JourneySelectionScreen extends StatelessWidget {
  const JourneySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101827),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: const Text('اختر مغامرتك'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'رحلة واحدة لكل الأعمار',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 28),
              _JourneyCard(
                icon: '🧒',
                title: 'مغامرة الأطفال',
                description: 'تعلّم والعب بأسئلة تناسب عمرك',
                colors: const [Color(0xFF38BDF8), Color(0xFF34D399)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlayerSelectionScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _JourneyCard(
                icon: '🧠',
                title: 'تحدي الكبار',
                description: 'اختبر معرفتك ومنطقك في مستويات متصاعدة',
                colors: const [Color(0xFF7C3AED), Color(0xFFDB2777)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdultPlayerScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _JourneyCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final List<Color> colors;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Ink(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(icon, style: const TextStyle(fontSize: 62)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ],
      ),
    ),
  );
}
