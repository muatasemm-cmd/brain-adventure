import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

class PlayerStorage {
  static const _playersKey = 'players_v1';
  static const _legacyPlayersRemovedKey = 'legacy_players_removed_v1';

  static Future<List<Player>> loadPlayers() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_playersKey);
    if (encoded == null) {
      return const [];
    }
    final entries = jsonDecode(encoded) as List<dynamic>;
    var players = entries
        .map((entry) => Player.fromJson(entry as Map<String, dynamic>))
        .toList();

    // Remove only the two profiles that older builds created automatically.
    // User-created profiles always use the player_<timestamp> identifier.
    if (!(preferences.getBool(_legacyPlayersRemovedKey) ?? false)) {
      players = players
          .where((player) => player.id != 'leen' && player.id != 'salah')
          .toList();
      await savePlayers(players);
      await preferences.setBool(_legacyPlayersRemovedKey, true);
    }
    return List.unmodifiable(players);
  }

  static Future<void> savePlayers(List<Player> players) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _playersKey,
      jsonEncode(players.map((player) => player.toJson()).toList()),
    );
  }

  static Future<List<Player>> addPlayer({
    required String name,
    required int age,
    required String avatar,
  }) async {
    final players = (await loadPlayers()).toList();
    players.add(
      Player(
        id: 'player_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        age: age,
        avatar: avatar,
      ),
    );
    await savePlayers(players);
    return players;
  }

  static Future<List<Player>> updatePlayer(Player updatedPlayer) async {
    final players = (await loadPlayers())
        .map((player) => player.id == updatedPlayer.id ? updatedPlayer : player)
        .toList();
    await savePlayers(players);
    return players;
  }

  static Future<List<Player>> deletePlayer(String playerId) async {
    final players = (await loadPlayers())
        .where((player) => player.id != playerId)
        .toList();
    await savePlayers(players);
    return players;
  }
}
