class AdultProgressRules {
  static bool isLevelCompleted(
    Map<String, int> progress,
    String categoryId,
    int level,
  ) => progress.containsKey('$categoryId:$level');

  static bool isLevelUnlocked(
    Map<String, int> progress,
    String categoryId,
    int level,
  ) => level == 1 || isLevelCompleted(progress, categoryId, level - 1);
}
