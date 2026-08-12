class AppSettings {
  final bool soundEffects;
  final bool music;
  final bool narrator;
  final bool haptics;

  const AppSettings({
    this.soundEffects = true,
    this.music = true,
    this.narrator = true,
    this.haptics = true,
  });

  AppSettings copyWith({
    bool? soundEffects,
    bool? music,
    bool? narrator,
    bool? haptics,
  }) => AppSettings(
    soundEffects: soundEffects ?? this.soundEffects,
    music: music ?? this.music,
    narrator: narrator ?? this.narrator,
    haptics: haptics ?? this.haptics,
  );
}
