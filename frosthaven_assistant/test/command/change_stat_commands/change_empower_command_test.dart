import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_empower_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    AddMonsterCommand("Zealot", 1, false).execute();
    AddStandeeCommand(1, null, "Zealot", MonsterType.normal, false).execute();
  });

  group('ChangeEmpowerCommand', () {
    test('should add an empowerment to a character', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      final command =
          ChangeEmpowerCommand(1, "in-empower", character.id, character.id);
      final initialEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      expect(finalEmpowerCount, initialEmpowerCount + 1);
      checkSaveState();
    });

    test('should remove an empowerment from a character', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      ChangeEmpowerCommand(1, "in-empower", character.id, character.id)
          .execute(); // Add an empowerment first
      final initialEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      final command =
          ChangeEmpowerCommand(-1, "in-empower", character.id, character.id);

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      expect(finalEmpowerCount, initialEmpowerCount - 1);
      checkSaveState();
    });

    test('should add an empowerment to a monster instance', () {
      // Arrange
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final monsterInstance = monster.monsterInstances.first;
      final command = ChangeEmpowerCommand(
          1, "in-empower", monster.id, monsterInstance.getId());
      final initialEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      expect(finalEmpowerCount, initialEmpowerCount + 1);
      checkSaveState();
    });

    test('should remove an empowerment from a monster instance', () {
      // Arrange
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final monsterInstance = monster.monsterInstances.first;
      ChangeEmpowerCommand(1, "in-empower", monster.id, monsterInstance.getId())
          .execute(); // Add an empowerment first
      final initialEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      final command = ChangeEmpowerCommand(
          -1, "in-empower", monster.id, monsterInstance.getId());

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      expect(finalEmpowerCount, initialEmpowerCount - 1);
      checkSaveState();
    });

    test('describe should return correct string for adding empowerment', () {
      // Arrange
      final command =
          ChangeEmpowerCommand(1, "in-empower", 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Add Empower');
    });

    test('describe should return correct string for removing empowerment', () {
      // Arrange
      final command =
          ChangeEmpowerCommand(-1, "in-empower", 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Remove Empower');
    });
  });
}
