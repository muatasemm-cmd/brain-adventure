import 'package:flutter/material.dart';

class MatchingGame extends StatefulWidget {
  final List<String> encodedPairs;
  final VoidCallback onComplete;
  final VoidCallback onWrong;
  final bool enabled;

  const MatchingGame({
    super.key,
    required this.encodedPairs,
    required this.onComplete,
    required this.onWrong,
    required this.enabled,
  });

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  String? selectedLeft;
  final matched = <String>{};

  Map<String, String> get pairs => {
    for (final encoded in widget.encodedPairs)
      encoded.split('|').first: encoded.split('|').last,
  };

  void chooseRight(String value) {
    final left = selectedLeft;
    if (left == null || !widget.enabled) return;
    if (pairs[left] == value) {
      setState(() {
        matched.add(left);
        selectedLeft = null;
      });
      if (matched.length == pairs.length) widget.onComplete();
    } else {
      setState(() => selectedLeft = null);
      widget.onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rightValues = pairs.values.toList().reversed.toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              const Text(
                'العنصر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final left in pairs.keys)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: OutlinedButton(
                    onPressed: widget.enabled && !matched.contains(left)
                        ? () => setState(() => selectedLeft = left)
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: matched.contains(left)
                          ? const Color(0xFFBBF7D0)
                          : selectedLeft == left
                          ? const Color(0xFFFEF3C7)
                          : null,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(left),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              const Text(
                'المطابقة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final right in rightValues)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ElevatedButton(
                    onPressed:
                        widget.enabled &&
                            !matched.contains(
                              pairs.entries
                                  .firstWhere((entry) => entry.value == right)
                                  .key,
                            )
                        ? () => chooseRight(right)
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(right),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
