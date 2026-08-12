import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 155,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 7)),
      ],
    ),
    child: Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(player.avatar, style: const TextStyle(fontSize: 70)),
                  const SizedBox(height: 10),
                  Text(
                    player.name,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    '${player.age} سنوات',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: PopupMenuButton<String>(
            tooltip: 'إدارة اللاعب',
            onSelected: (action) {
              if (action == 'edit') onEdit();
              if (action == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ),
      ],
    ),
  );
}
