import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/adventure_progress_storage.dart';
import '../services/player_storage.dart';
import '../widgets/player_card.dart';
import 'adventure_home_screen.dart';
import 'parent_dashboard_screen.dart';
import 'placement_test_screen.dart';
import '../services/learning_support_service.dart';

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<Player> players = const [];
  bool loading = true;
  bool creationPromptShown = false;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    final loaded = await PlayerStorage.loadPlayers();
    if (mounted) {
      setState(() {
        players = loaded;
        loading = false;
      });
      if (loaded.isEmpty && !creationPromptShown) {
        creationPromptShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showPlayerDialog(null);
        });
      }
    }
  }

  Future<void> showPlayerDialog(Player? existing) async {
    final controller = TextEditingController(text: existing?.name);
    final nameFocusNode = FocusNode();
    var age = existing?.age ?? 8;
    var avatar = existing?.avatar ?? '🧒';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'إضافة لاعب جديد' : 'تعديل اللاعب',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  focusNode: nameFocusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطفل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: age,
                  decoration: const InputDecoration(
                    labelText: 'العمر',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var value = 5; value <= 14; value++)
                      DropdownMenuItem(
                        value: value,
                        child: Text('$value سنوات'),
                      ),
                  ],
                  onChanged: (value) => age = value ?? age,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: ['🧒', '👧', '👦', '🧕', '🦸'].map((value) {
                    return ChoiceChip(
                      label: Text(value, style: const TextStyle(fontSize: 24)),
                      selected: avatar == value,
                      onSelected: (_) => setDialogState(() => avatar = value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(existing == null ? 'إضافة' : 'حفظ'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (accepted == true) {
      players = existing == null
          ? await PlayerStorage.addPlayer(
              name: controller.text,
              age: age,
              avatar: avatar,
            )
          : await PlayerStorage.updatePlayer(
              existing.copyWith(
                name: controller.text.trim(),
                age: age,
                avatar: avatar,
              ),
            );
      if (mounted) setState(() {});
    }
    nameFocusNode.dispose();
    controller.dispose();
  }

  Future<void> deletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف اللاعب؟', textAlign: TextAlign.center),
        content: Text(
          'سيتم حذف ملف ${player.name} وتقدمه المحفوظ.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    players = await PlayerStorage.deletePlayer(player.id);
    await Future.wait([AdventureProgressStorage.delete(player.id)]);
    if (mounted) setState(() {});
  }

  Future<void> openPlayer(Player player) async {
    final hasPlacement = await LearningSupportService.hasPlacement(player.id);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => !hasPlacement
            ? PlacementTestScreen(player: player)
            : AdventureHomeScreen(player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64C4EE), Color(0xFF8BE0B1)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'اختر المغامر',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'منطقة ولي الأمر',
                    onPressed: () => ParentDashboardScreen.open(context),
                    icon: const Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'من سيلعب اليوم؟ 🎮',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : players.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 92,
                              color: Colors.white,
                            ),
                            SizedBox(height: 18),
                            Text(
                              'أنشئ ملفك لتبدأ المغامرة',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'سنختار الأسئلة المناسبة لعمرك',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (final player in players)
                                PlayerCard(
                                  player: player,
                                  onTap: () => openPlayer(player),
                                  onEdit: () => showPlayerDialog(player),
                                  onDelete: () => deletePlayer(player),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
              ElevatedButton.icon(
                onPressed: () => showPlayerDialog(null),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'إضافة لاعب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(230, 58),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
