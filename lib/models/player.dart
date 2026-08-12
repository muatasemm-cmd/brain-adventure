class Player {
  final String id;
  final String name;
  final int age;
  final String avatar;
  final List<String> ownedRewardIds;
  final String? equippedRewardId;

  const Player({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    this.ownedRewardIds = const [],
    this.equippedRewardId,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'avatar': avatar,
    'ownedRewardIds': ownedRewardIds,
    'equippedRewardId': ?equippedRewardId,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
    avatar: json['avatar'] as String,
    ownedRewardIds: [
      for (final id in json['ownedRewardIds'] as List? ?? const [])
        id.toString(),
    ],
    equippedRewardId: json['equippedRewardId'] as String?,
  );

  Player copyWith({
    String? name,
    int? age,
    String? avatar,
    List<String>? ownedRewardIds,
    String? equippedRewardId,
    bool clearEquippedReward = false,
  }) => Player(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    avatar: avatar ?? this.avatar,
    ownedRewardIds: ownedRewardIds ?? this.ownedRewardIds,
    equippedRewardId: clearEquippedReward
        ? null
        : equippedRewardId ?? this.equippedRewardId,
  );
}
