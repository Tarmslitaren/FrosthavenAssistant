import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_max_health_command.dart';
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

  group('ChangeMaxHealthCommand', () {
    test('should increase a character\'s max health', () {
      // Arrange
      final initialMaxHealth = character.characterState.maxHealth.value;
      final command = ChangeMaxHealthCommand(5, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.maxHealth.value, initialMaxHealth + 5);
    });

    test('should decrease a character\'s max health', () {
      // Arrange
      final initialMaxHealth = character.characterState.maxHealth.value;
      final command = ChangeMaxHealthCommand(-2, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.maxHealth.value, initialMaxHealth - 2);
    });

    test('should lower current health if it exceeds new max health', () {
      // Arrange
      final initialHealth = character.characterState.health.value;
      expect(initialHealth, equals(character.characterState.maxHealth.value));
      final command = ChangeMaxHealthCommand(-3, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value,
          character.characterState.maxHealth.value);
    });

    test(
        'should update current health when max health changes if they were equal',
        () {
      // Arrange
      final command = ChangeMaxHealthCommand(5, character.id, character.id);
      final initialHealth = character.characterState.health.value;
      final initialMaxHealth = character.characterState.maxHealth.value;
      expect(initialHealth, initialMaxHealth);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.health.value, initialHealth + 5);
      expect(character.characterState.maxHealth.value, initialMaxHealth + 5);
    });

    test('should not set max health to 0 or below', () {
      // Arrange
      final initialMaxHealth = character.characterState.maxHealth.value;
      final command = ChangeMaxHealthCommand(-100, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.maxHealth.value, initialMaxHealth);
    });

    test('should increase a monster instance\'s max health', () {
      // Arrange
      final initialMaxHealth = monsterInstance.maxHealth.value;
      final command =
          ChangeMaxHealthCommand(3, monsterInstance.getId(), monster.id);

      // Act
      command.execute();

      // Assert
      expect(monsterInstance.maxHealth.value, initialMaxHealth + 3);
    });

    test('undo should not revert max health change (as currently implemented)',
        () {
      // Arrange
      final initialMaxHealth = character.characterState.maxHealth.value;
      final command = ChangeMaxHealthCommand(5, character.id, character.id);
      command.execute();

      // Act
      command.undo();

      // Assert
      expect(character.characterState.maxHealth.value, initialMaxHealth + 5);
    });

    test('describe should return correct string for increasing max health', () {
      final command = ChangeMaxHealthCommand(5, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Increase Blinkblade's max health");
    });

    test('describe should return correct string for decreasing max health', () {
      final command = ChangeMaxHealthCommand(-5, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Decrease Blinkblade's max health");
    });
  });
}
