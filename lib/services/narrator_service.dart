import 'settings_storage.dart';
import 'narrator_platform.dart'
    if (dart.library.js_interop) 'narrator_web.dart'
    as platform;

class NarratorService {
  static Future<void> speak(String text) async {
    final settings = await SettingsStorage.load();
    if (!settings.narrator) return;
    await platform.speak(text);
  }

  static Future<void> stop() async {
    await platform.stop();
  }
}
