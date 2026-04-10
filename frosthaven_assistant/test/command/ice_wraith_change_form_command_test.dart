import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/ice_wraith_change_form_command.dart';
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
    AddMonsterCommand('Ancient Artillery (FH)', 1, false, gameState: getIt<GameState>()).execute();
    AddStandeeCommand(
            1, null, 'Ancient Artillery (FH)', MonsterType.normal, false, gameState: getIt<GameState>())
        .execute();
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterInstance = monster.monsterInstances.first;
  });

  group('IceWraithChangeFormCommand', () {
    test('should change type to elite when isElite is false', () {
      expect(monsterInstance.type, MonsterType.normal);

      IceWraithChangeFormCommand(false, monster.id, monsterInstance.getId(), gameState: getIt<GameState>())
          .execute();

      expect(monsterInstance.type, MonsterType.elite);
    });

    test('should change type to normal when isElite is true', () {
      // First set to elite
      IceWraithChangeFormCommand(false, monster.id, monsterInstance.getId(), gameState: getIt<GameState>())
          .execute();
      expect(monsterInstance.type, MonsterType.elite);

      IceWraithChangeFormCommand(true, monster.id, monsterInstance.getId(), gameState: getIt<GameState>())
          .execute();

      expect(monsterInstance.type, MonsterType.normal);
    });

    test('describe when isElite is false returns turn-normal string', () {
      final command = IceWraithChangeFormCommand(
          false, monster.id, monsterInstance.getId(), gameState: getIt<GameState>());
      expect(command.describe(), 'Ice Wraith turn normal');
    });

    test('describe when isElite is true returns turn-elite string', () {
      final command = IceWraithChangeFormCommand(
          true, monster.id, monsterInstance.getId(), gameState: getIt<GameState>());
      expect(command.describe(), 'Ice Wraith turn elite');
    });
  });
}
