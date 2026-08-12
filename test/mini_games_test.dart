import 'package:brain_adventure/games/matching_game.dart';
import 'package:brain_adventure/games/memory_game.dart';
import 'package:brain_adventure/games/ordering_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('لعبة الترتيب تعيد التسلسل المختار', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderingGame(
            items: const ['16', '2', '8', '4'],
            enabled: true,
            onSubmit: (value) => result = value,
          ),
        ),
      ),
    );
    for (final value in ['2', '4', '8', '16']) {
      await tester.tap(find.widgetWithText(ElevatedButton, value));
      await tester.pump();
    }
    await tester.tap(find.text('تحقق من الترتيب'));
    expect(result, '2|4|8|16');
  });

  testWidgets('لعبة المطابقة تكتمل بعد ربط كل زوج', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchingGame(
            encodedPairs: const ['قطة|تموء', 'نحلة|عسل'],
            enabled: true,
            onComplete: () => completed = true,
            onWrong: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('قطة'));
    await tester.tap(find.text('تموء'));
    await tester.pump();
    await tester.tap(find.text('نحلة'));
    await tester.tap(find.text('عسل'));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets('لعبة الذاكرة تكمل زوجًا متطابقًا', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoryGame(
            symbols: const ['🍎'],
            enabled: true,
            onComplete: () => completed = true,
            onWrong: () {},
          ),
        ),
      ),
    );
    final cards = find.byType(InkWell);
    await tester.tap(cards.at(0));
    await tester.tap(cards.at(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(completed, isTrue);
  });
}
