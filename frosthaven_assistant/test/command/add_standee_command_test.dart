import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;
  late Monster monster;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    AddMonsterCommand("Ancient Artillery (FH)", 1, false).execute();

    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
  });

  group('AddStandeeCommand', () {
    test('should add a standee to a monster', () {
      // Arrange
      final command =
          AddStandeeCommand(1, null, monster.id, MonsterType.normal, false);

      // Act
      command.execute();

      // Assert
      final updatedMonster = getIt<GameState>()
          .currentList
          .firstWhere((m) => m.id == monster.id) as Monster;
      expect(updatedMonster.monsterInstances.length, 1);
      expect(updatedMonster.monsterInstances.first.standeeNr, 1);
      checkSaveState();
    });

    test('should add a summon to a character', () {
      // Arrange
      final summonData = SummonData(1, 'Test Summon', 10, 2, 2, 0, 'test_gfx');
      final command = AddStandeeCommand(
          1, summonData, character.id, MonsterType.summon, true);

      // Act
      command.execute();

      // Assert
      final updatedCharacter = getIt<GameState>()
          .currentList
          .firstWhere((c) => c.id == character.id) as Character;
      expect(updatedCharacter.characterState.summonList.length, 1);
      expect(
          updatedCharacter.characterState.summonList.first.name, 'Test Summon');
      checkSaveState();
    });

    test('undo should not remove the standee (as currently implemented)', () {
      // Arrange
      final command =
          AddStandeeCommand(1, null, monster.id, MonsterType.normal, false);
      command.execute();
      final monsterAfterExecute = getIt<GameState>()
          .currentList
          .firstWhere((m) => m.id == monster.id) as Monster;
      final instanceCount = monsterAfterExecute.monsterInstances.length;

      // Act
      command.undo();

      // Assert
      // The undo method is incomplete and only increments updateList.
      expect(monsterAfterExecute.monsterInstances.length, instanceCount);
    });

    test('describe should return correct string for a monster standee', () {
      // Arrange
      final command =
          AddStandeeCommand(1, null, monster.id, MonsterType.normal, false);

      // Act & Assert
      expect(command.describe(), 'Add Ancient Artillery (FH) 1');
    });

    test('describe should return correct string for a summon', () {
      // Arrange
      final summonData = SummonData(1, 'Test Summon', 10, 2, 2, 0, 'test_gfx');
      final command = AddStandeeCommand(
          1, summonData, character.id, MonsterType.summon, true);

      // Act & Assert
      expect(command.describe(), 'Add Test Summon 1');
    });
  });
}
