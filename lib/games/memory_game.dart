import 'dart:math';

import 'package:flutter/material.dart';

class MemoryGame extends StatefulWidget {
  final List<String> symbols;
  final VoidCallback onComplete;
  final VoidCallback onWrong;
  final bool enabled;

  const MemoryGame({
    super.key,
    required this.symbols,
    required this.onComplete,
    required this.onWrong,
    required this.enabled,
  });

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late final List<String> cards;
  final revealed = <int>[];
  final matched = <int>{};
  bool checking = false;

  @override
  void initState() {
    super.initState();
    cards = [...widget.symbols, ...widget.symbols]
      ..shuffle(Random(widget.symbols.join().hashCode));
  }

  Future<void> reveal(int index) async {
    if (!widget.enabled ||
        checking ||
        matched.contains(index) ||
        revealed.contains(index)) {
      return;
    }
    setState(() => revealed.add(index));
    if (revealed.length < 2) return;
    checking = true;
    final first = revealed[0];
    final second = revealed[1];
    if (cards[first] == cards[second]) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        matched.addAll([first, second]);
        revealed.clear();
        checking = false;
      });
      if (matched.length == cards.length) widget.onComplete();
    } else {
      widget.onWrong();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        revealed.clear();
        checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: cards.length,
    itemBuilder: (context, index) {
      final visible = revealed.contains(index) || matched.contains(index);
      return InkWell(
        onTap: () => reveal(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: matched.contains(index)
                ? const Color(0xFFBBF7D0)
                : visible
                ? Colors.white
                : const Color(0xFF60A5FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            visible ? cards[index] : '❓',
            style: const TextStyle(fontSize: 34),
          ),
        ),
      );
    },
  );
}
