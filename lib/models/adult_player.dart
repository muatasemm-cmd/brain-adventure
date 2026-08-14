class AdultPlayer {
  final String id;
  final String name;
  final String ageGroup;
  final String level;

  const AdultPlayer({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.level,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'ageGroup': ageGroup,
    'level': level,
  };

  factory AdultPlayer.fromJson(Map<String, dynamic> json) => AdultPlayer(
    id: json['id'] as String,
    name: json['name'] as String,
    ageGroup: json['ageGroup'] as String,
    level: json['level'] as String,
  );
}
