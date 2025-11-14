import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

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
    AddMonsterCommand("Zealot", 1, false).execute();
    AddStandeeCommand(1, null, "Zealot", MonsterType.normal, false).execute();

    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterInstance = monster.monsterInstances.first;
  });

  group('ChangeHealthCommand', () {
    test('should increase a character\'s health', () {
      // Arrange
      final initialHealth = character.characterState.health.value;
      final command = ChangeHealthCommand(5, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value, initialHealth + 5);
    });

    test('should decrease a character\'s health', () {
      // Arrange
      final initialHealth = character.characterState.health.value;
      final command = ChangeHealthCommand(-5, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value, initialHealth - 5);
    });

    test('should kill a character when health reaches 0', () {
      // Arrange
      final command = ChangeHealthCommand(-100, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value, 0);
      // A killed character's turn should be marked as done. this is not true
      //expect(character.turnState.value, TurnsState.done);
    });

    test('should increase a monster instance\'s health', () {
      // Arrange
      final initialHealth = monsterInstance.health.value;
      final command =
          ChangeHealthCommand(3, monsterInstance.getId(), monster.id);

      // Act
      command.execute();

      // Assert
      expect(monsterInstance.health.value, initialHealth + 3);
    });

    test('should kill a monster instance when health reaches 0', () {
      // Arrange
      final command =
          ChangeHealthCommand(-100, monsterInstance.getId(), monster.id);
      final initialInstanceCount = monster.monsterInstances.length;

      // Act
      command.execute();

      // Assert
      expect(monster.monsterInstances.length, initialInstanceCount - 1);
    });

    test('should not decrease health below 0', () {
      // Arrange
      final command = ChangeHealthCommand(-100, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value, 0);
    });

    test('undo should not revert health change (as currently implemented)', () {
      // Arrange
      final initialHealth = character.characterState.health.value;
      final command = ChangeHealthCommand(5, character.id, character.id);
      command.execute();

      // Act
      command.undo();

      // Assert
      // The undo method is incomplete and does not revert the health.
      // This test verifies the current behavior.
      expect(character.characterState.health.value, initialHealth + 5);
    });

    test('describe should return correct string for increasing health', () {
      final command = ChangeHealthCommand(5, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Increase Blinkblade's health by 5");
    });

    test('describe should return correct string for decreasing health', () {
      final command = ChangeHealthCommand(-5, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Decrease Blinkblade's health by 5");
    });

    test('describe should return kill string if health is already 0', () {
      // Arrange
      //character.characterState.setHealth(StateModifier(), 0);
      ChangeHealthCommand(-100, character.id, character.id).execute();
      final command = ChangeHealthCommand(-1, character.id, character.id);

      // Act & Assert
      expect(command.describe(), 'Kill Blinkblade');
    });
  });
}
