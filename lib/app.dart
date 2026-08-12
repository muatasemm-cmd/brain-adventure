import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

class BrainAdventureApp extends StatelessWidget {
  const BrainAdventureApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'رحلة العباقرة',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22C55E)),
    ),
    home: const WelcomeScreen(),
  );
}
