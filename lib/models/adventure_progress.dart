class AdventureProgress {
  final int stars;
  final int coins;
  final int crystals;
  final Set<String> completedChallenges;
  final Map<String, int> correctBySubject;
  final Map<String, int> attemptsBySubject;
  final int totalPlaySeconds;
  final String? lastPlayedAt;

  const AdventureProgress({
    this.stars = 0,
    this.coins = 0,
    this.crystals = 0,
    this.completedChallenges = const {},
    this.correctBySubject = const {},
    this.attemptsBySubject = const {},
    this.totalPlaySeconds = 0,
    this.lastPlayedAt,
  });

  Map<String, Object> toJson() => {
    'stars': stars,
    'coins': coins,
    'crystals': crystals,
    'completedChallenges': completedChallenges.toList(),
    'correctBySubject': correctBySubject,
    'attemptsBySubject': attemptsBySubject,
    'totalPlaySeconds': totalPlaySeconds,
    'lastPlayedAt': ?lastPlayedAt,
  };

  factory AdventureProgress.fromJson(Map<String, dynamic> json) {
    Map<String, int> intMap(Object? value) => (value as Map? ?? const {}).map(
      (key, count) => MapEntry(key.toString(), count as int),
    );

    return AdventureProgress(
      stars: json['stars'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      crystals: json['crystals'] as int? ?? 0,
      completedChallenges: {
        for (final id in json['completedChallenges'] as List? ?? const [])
          id.toString(),
      },
      correctBySubject: intMap(json['correctBySubject']),
      attemptsBySubject: intMap(json['attemptsBySubject']),
      totalPlaySeconds: json['totalPlaySeconds'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] as String?,
    );
  }

  AdventureProgress copyWith({
    int? stars,
    int? coins,
    int? crystals,
    Set<String>? completedChallenges,
    Map<String, int>? correctBySubject,
    Map<String, int>? attemptsBySubject,
    int? totalPlaySeconds,
    String? lastPlayedAt,
  }) => AdventureProgress(
    stars: stars ?? this.stars,
    coins: coins ?? this.coins,
    crystals: crystals ?? this.crystals,
    completedChallenges: completedChallenges ?? this.completedChallenges,
    correctBySubject: correctBySubject ?? this.correctBySubject,
    attemptsBySubject: attemptsBySubject ?? this.attemptsBySubject,
    totalPlaySeconds: totalPlaySeconds ?? this.totalPlaySeconds,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
  );
}
