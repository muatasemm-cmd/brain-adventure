import 'package:flutter/material.dart';

class OrderingGame extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onSubmit;
  final bool enabled;

  const OrderingGame({
    super.key,
    required this.items,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  State<OrderingGame> createState() => _OrderingGameState();
}

class _OrderingGameState extends State<OrderingGame> {
  final selected = <String>[];

  @override
  Widget build(BuildContext context) {
    final remaining = widget.items.where((item) => !selected.contains(item));
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 65),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < selected.length; index++)
                Chip(label: Text('${index + 1}. ${selected[index]}')),
              if (selected.isEmpty)
                const Text(
                  'اضغط العناصر بالترتيب الصحيح',
                  textDirection: TextDirection.rtl,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in remaining)
              ElevatedButton(
                onPressed: widget.enabled
                    ? () => setState(() => selected.add(item))
                    : null,
                child: Text(item, style: const TextStyle(fontSize: 20)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: widget.enabled && selected.isNotEmpty
                  ? () => setState(selected.clear)
                  : null,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed:
                  widget.enabled && selected.length == widget.items.length
                  ? () => widget.onSubmit(selected.join('|'))
                  : null,
              child: const Text('تحقق من الترتيب'),
            ),
          ],
        ),
      ],
    );
  }
}
