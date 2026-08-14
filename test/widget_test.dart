// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_adventure/main.dart';

void main() {
  testWidgets('تظهر شاشة الترحيب وتفتح اختيار اللاعب', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BrainAdventureApp());

    expect(find.text('رحلة العباقرة'), findsOneWidget);
    expect(find.text('ابدأ المغامرة'), findsOneWidget);

    await tester.tap(find.text('ابدأ المغامرة'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('اختر مغامرتك'), findsOneWidget);
    expect(find.text('مغامرة الأطفال'), findsOneWidget);
    expect(find.text('تحدي الكبار'), findsOneWidget);
  });
}
