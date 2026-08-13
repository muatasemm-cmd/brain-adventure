import 'dart:math' as math;

import 'package:flutter/material.dart';

class FireworksCelebration extends StatefulWidget {
  const FireworksCelebration({super.key});

  @override
  State<FireworksCelebration> createState() => _FireworksCelebrationState();
}

class _FireworksCelebrationState extends State<FireworksCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(
      painter: _FireworksPainter(controller.value),
      size: Size.infinite,
    ),
  );
}

class _FireworksPainter extends CustomPainter {
  final double progress;
  const _FireworksPainter(this.progress);

  static const colors = [
    Color(0xFFFFD54F),
    Color(0xFFFF5252),
    Color(0xFF40C4FF),
    Color(0xFF69F0AE),
    Color(0xFFE040FB),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centers = [
      Offset(size.width * .2, size.height * .25),
      Offset(size.width * .8, size.height * .22),
      Offset(size.width * .5, size.height * .12),
    ];
    for (var burst = 0; burst < centers.length; burst++) {
      final phase = (progress + burst * .27) % 1;
      final radius = 25 + phase * 115;
      final alpha = (1 - phase).clamp(0.0, 1.0);
      for (var ray = 0; ray < 16; ray++) {
        final angle = ray * math.pi * 2 / 16;
        final point =
            centers[burst] + Offset(math.cos(angle), math.sin(angle)) * radius;
        canvas.drawCircle(
          point,
          5 * (1 - phase * .45),
          Paint()
            ..color = colors[(ray + burst) % colors.length].withValues(
              alpha: alpha,
            ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
