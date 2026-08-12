import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsStorage {
  static const _effectsKey = 'settings_effects_v1';
  static const _musicKey = 'settings_music_v1';
  static const _narratorKey = 'settings_narrator_v1';
  static const _hapticsKey = 'settings_haptics_v1';

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings(
      soundEffects: preferences.getBool(_effectsKey) ?? true,
      music: preferences.getBool(_musicKey) ?? true,
      narrator: preferences.getBool(_narratorKey) ?? true,
      haptics: preferences.getBool(_hapticsKey) ?? true,
    );
  }

  static Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_effectsKey, settings.soundEffects),
      preferences.setBool(_musicKey, settings.music),
      preferences.setBool(_narratorKey, settings.narrator),
      preferences.setBool(_hapticsKey, settings.haptics),
    ]);
  }

  static Future<void> successFeedback() async {
    final settings = await load();
    if (settings.soundEffects) await SystemSound.play(SystemSoundType.click);
    if (settings.haptics) await HapticFeedback.lightImpact();
  }

  static Future<void> errorFeedback() async {
    final settings = await load();
    if (settings.soundEffects) await SystemSound.play(SystemSoundType.alert);
    if (settings.haptics) await HapticFeedback.vibrate();
  }
}
