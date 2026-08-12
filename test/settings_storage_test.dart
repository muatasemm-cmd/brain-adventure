import 'package:brain_adventure/models/app_settings.dart';
import 'package:brain_adventure/services/settings_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('يحفظ إعدادات الصوت والاهتزاز دون إنترنت', () async {
    const settings = AppSettings(
      soundEffects: false,
      music: false,
      narrator: true,
      haptics: false,
    );
    await SettingsStorage.save(settings);
    final loaded = await SettingsStorage.load();
    expect(loaded.soundEffects, isFalse);
    expect(loaded.music, isFalse);
    expect(loaded.narrator, isTrue);
    expect(loaded.haptics, isFalse);
  });
}
