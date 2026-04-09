import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_as_summon_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Monster monster;
  late MonsterInstance monsterInstance;

  setUp(() {
    getIt<GameState>().clearList();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
    AddStandeeCommand(
            1, null, 'Ancient Artillery (FH)', MonsterType.normal, false)
        .execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterInstance = monster.monsterInstances.first;
  });

  group('SetAsSummonCommand', () {
    test('should mark a monster instance as summoned', () {
      SetAsSummonCommand(true, monsterInstance.getId(), monster.id).execute();
      expect(monsterInstance.roundSummoned,
          greaterThanOrEqualTo(1));
    });

    test('should clear summon mark when summoned is false', () {
      SetAsSummonCommand(true, monsterInstance.getId(), monster.id).execute();
      SetAsSummonCommand(false, monsterInstance.getId(), monster.id).execute();
      expect(monsterInstance.roundSummoned, -1);
    });

    test('describe when summoned is true mentions mark', () {
      final command =
          SetAsSummonCommand(true, monsterInstance.getId(), monster.id);
      expect(command.describe(), contains('summon'));
    });

    test('describe when summoned is false mentions remove', () {
      final command =
          SetAsSummonCommand(false, monsterInstance.getId(), monster.id);
      expect(command.describe(), contains('Remove'));
    });
  });
}
