import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
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
  late MonsterInstance monsterInstance;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    AddMonsterCommand("Ancient Artillery (FH)", 1, false).execute();
    AddStandeeCommand(
            1, null, "Ancient Artillery (FH)", MonsterType.normal, false)
        .execute();

    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterInstance = monster.monsterInstances.first;
  });

  group('AddConditionCommand', () {
    test('should add a condition to a character', () {
      // Arrange
      final command =
          AddConditionCommand(Condition.poison, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.conditions.value,
          contains(Condition.poison));
    });

    test('should add a condition to a monster instance', () {
      // Arrange
      final command = AddConditionCommand(
          Condition.wound, monsterInstance.getId(), monster.id);

      // Act
      command.execute();

      // Assert
      expect(monsterInstance.conditions.value, contains(Condition.wound));
    });

    test('should increment chill counter when adding CHILL condition', () {
      // Arrange
      final command1 =
          AddConditionCommand(Condition.chill, character.id, character.id);
      final command2 =
          AddConditionCommand(Condition.chill, character.id, character.id);

      // Act
      command1.execute();
      command2.execute();

      // Assert
      expect(character.characterState.chill.value, 2);
      // The list will contain two chill entries
      expect(
          character.characterState.conditions.value
              .where((c) => c == Condition.chill)
              .length,
          2);
    });

    test('should not add a duplicate non-stacking condition', () {
      // Arrange
      final command1 =
          AddConditionCommand(Condition.poison, character.id, character.id);
      final command2 =
          AddConditionCommand(Condition.poison, character.id, character.id);

      // Act
      command1.execute();
      command2.execute();

      // Assert
      expect(
          character.characterState.conditions.value
              .where((c) => c == Condition.poison)
              .length,
          1);
    });

    test('undo should not revert adding a condition (as currently implemented)',
        () {
      // Arrange
      final command =
          AddConditionCommand(Condition.poison, character.id, character.id);
      command.execute();
      final conditionsAfterExecute =
          List.from(character.characterState.conditions.value);

      // Act
      command.undo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(character.characterState.conditions.value,
          orderedEquals(conditionsAfterExecute));
    });

    test('describe should return correct string for character', () {
      // Arrange
      final command =
          AddConditionCommand(Condition.muddle, character.id, character.id);

      // Act & Assert
      expect(command.describe(), 'Add condition: muddle');
    });

    test('describe should return correct string for monster', () {
      // Arrange
      final command = AddConditionCommand(
          Condition.stun, monster.id, monsterInstance.getId());

      // Act & Assert
      expect(command.describe(), 'Add condition: stun');
    });
  });
}
