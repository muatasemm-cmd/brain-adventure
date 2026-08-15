class AdultProgressRules {
  static bool isLevelCompleted(
    Map<String, int> progress,
    String categoryId,
    int level,
  ) => progress.containsKey('$categoryId:$level');

  static bool isLevelUnlocked(
    Map<String, int> progress,
    String categoryId,
    int level, {
    int placementStart = 1,
  }) =>
      level <= placementStart ||
      isLevelCompleted(progress, categoryId, level - 1);
}
