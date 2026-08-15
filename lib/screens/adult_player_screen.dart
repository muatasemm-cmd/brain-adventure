import 'package:flutter/material.dart';

import '../models/adult_player.dart';
import '../services/adult_storage.dart';
import 'adult_dashboard_screen.dart';
import 'adult_placement_screen.dart';

class AdultPlayerScreen extends StatefulWidget {
  const AdultPlayerScreen({super.key});

  @override
  State<AdultPlayerScreen> createState() => _AdultPlayerScreenState();
}

class _AdultPlayerScreenState extends State<AdultPlayerScreen> {
  List<AdultPlayer> players = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    players = await AdultStorage.loadPlayers();
    if (mounted) setState(() => loading = false);
  }

  Future<void> createPlayer() async {
    final controller = TextEditingController();
    var ageGroup = '18–29';
    var level = 'مبتدئ';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ملف تحدي الكبار', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: ageGroup,
                  decoration: const InputDecoration(
                    labelText: 'الفئة العمرية',
                    border: OutlineInputBorder(),
                  ),
                  items: ['18–29', '30–44', '45–59', '60+']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => ageGroup = value ?? ageGroup,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: level,
                  decoration: const InputDecoration(
                    labelText: 'مستواك المبدئي',
                    border: OutlineInputBorder(),
                  ),
                  items: ['مبتدئ', 'متوسط', 'متقدم']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => level = value ?? level,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('ابدأ'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      players = await AdultStorage.addPlayer(
        name: controller.text,
        ageGroup: ageGroup,
        level: level,
      );
      if (mounted) setState(() {});
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF101827),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: const Text('ملفات المتحدّين'),
      centerTitle: true,
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: createPlayer,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('ملف جديد'),
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : players.isEmpty
        ? Center(
            child: FilledButton.icon(
              onPressed: createPlayer,
              icon: const Icon(Icons.add),
              label: const Text('أنشئ ملفك وابدأ التحدي'),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: players.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(radius: 28, child: Text('🧠')),
                  title: Text(
                    player.name,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    '${player.ageGroup} • ${player.level}',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () async {
                      players = await AdultStorage.deletePlayer(player.id);
                      if (mounted) setState(() {});
                    },
                  ),
                  onTap: () async {
                    final placement = await AdultStorage.loadPlacement(
                      player.id,
                    );
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => placement == null
                            ? AdultPlacementScreen(player: player)
                            : AdultDashboardScreen(player: player),
                      ),
                    );
                  },
                ),
              );
            },
          ),
  );
}
