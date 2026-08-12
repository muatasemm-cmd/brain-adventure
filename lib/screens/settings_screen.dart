import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings? settings;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final loaded = await SettingsStorage.load();
    if (mounted) setState(() => settings = loaded);
  }

  Future<void> update(AppSettings value) async {
    setState(() => settings = value);
    await SettingsStorage.save(value);
  }

  @override
  Widget build(BuildContext context) {
    final value = settings;
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ الإعدادات'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: value == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingSwitch(
                  icon: '🔔',
                  title: 'المؤثرات الصوتية',
                  subtitle: 'أصوات الإجابة والأزرار',
                  value: value.soundEffects,
                  onChanged: (enabled) =>
                      update(value.copyWith(soundEffects: enabled)),
                ),
                _SettingSwitch(
                  icon: '🎵',
                  title: 'الموسيقى',
                  subtitle: 'جاهزة لإضافة موسيقى العوالم الأصلية',
                  value: value.music,
                  onChanged: (enabled) =>
                      update(value.copyWith(music: enabled)),
                ),
                _SettingSwitch(
                  icon: '🗣️',
                  title: 'صوت الراوي',
                  subtitle: 'جاهز لقراءة الأسئلة عند إضافة التسجيلات',
                  value: value.narrator,
                  onChanged: (enabled) =>
                      update(value.copyWith(narrator: enabled)),
                ),
                _SettingSwitch(
                  icon: '📳',
                  title: 'الاهتزاز',
                  subtitle: 'رد فعل لطيف عند الإجابة',
                  value: value.haptics,
                  onChanged: (enabled) =>
                      update(value.copyWith(haptics: enabled)),
                ),
                const SizedBox(height: 18),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'اللعبة تعمل دون إنترنت، وجميع بيانات الأطفال محفوظة على هذا الجهاز.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: SwitchListTile(
      secondary: Text(icon, style: const TextStyle(fontSize: 30)),
      title: Text(title, textDirection: TextDirection.rtl),
      subtitle: Text(subtitle, textDirection: TextDirection.rtl),
      value: value,
      onChanged: onChanged,
    ),
  );
}
