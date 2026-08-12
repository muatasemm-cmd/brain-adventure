import 'package:flutter/services.dart';

import 'settings_storage.dart';

class NarratorService {
  static const _channel = MethodChannel('brain_adventure/narrator');

  static Future<void> speak(String text) async {
    final settings = await SettingsStorage.load();
    if (!settings.narrator) return;
    try {
      await _channel.invokeMethod<void>('speak', {'text': text});
    } on MissingPluginException {
      // The web build has no native speech channel. Keep play uninterrupted.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing is speaking through the native channel on web.
    }
  }
}
