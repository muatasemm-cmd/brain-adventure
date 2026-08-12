import 'package:brain_adventure/services/player_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('يبدأ دون حسابات افتراضية', () async {
    expect(await PlayerStorage.loadPlayers(), isEmpty);
  });

  test('يحفظ اللاعب ويعدله ويحذفه', () async {
    var players = await PlayerStorage.addPlayer(
      name: 'أحمد',
      age: 9,
      avatar: '🧑',
    );
    final added = players.single;
    expect(added.name, 'أحمد');
    expect(added.age, 9);

    players = await PlayerStorage.updatePlayer(
      added.copyWith(name: 'أحمد البطل', age: 10),
    );
    expect(players.single.name, 'أحمد البطل');
    expect(players.single.age, 10);

    players = await PlayerStorage.deletePlayer(added.id);
    expect(players, isEmpty);
  });

  test('يزيل لين وصلاح اللذين أنشأتهما النسخة القديمة', () async {
    SharedPreferences.setMockInitialValues({
      'players_v1':
          '[{"id":"leen","name":"لين","age":8,"avatar":"👧","ownedRewardIds":[]},{"id":"salah","name":"صلاح","age":10,"avatar":"👦","ownedRewardIds":[]}]',
    });
    expect(await PlayerStorage.loadPlayers(), isEmpty);
  });
}
