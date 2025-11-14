import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_curse_command.dart';
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
    AddStandeeCommand(1, null, "Zealot", MonsterType.normal, false);
  });

  group('ChangeCurseCommand', () {
    test('should add a curse card to a character deck', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      final command = ChangeCurseCommand(1, character.id, character.id);
      final initialCurseCount =
          character.characterState.modifierDeck.getRemovable("curse").value;

      // Act
      command.execute();

      // Assert
      final finalCurseCount =
          character.characterState.modifierDeck.getRemovable("curse").value;
      expect(finalCurseCount, initialCurseCount + 1);
      checkSaveState();
    });

    test('should remove a curse card from a character deck', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      ChangeCurseCommand(1, character.id, character.id)
          .execute(); // Add a curse first
      final initialCurseCount =
          character.characterState.modifierDeck.getRemovable("curse").value;
      final command = ChangeCurseCommand(-1, character.id, character.id);

      // Act
      command.execute();

      // Assert
      final finalCurseCount =
          character.characterState.modifierDeck.getRemovable("curse").value;
      expect(finalCurseCount, initialCurseCount - 1);
      checkSaveState();
    });

    test('should add a curse card to the monster deck', () {
      // Arrange
      final gameState = getIt<GameState>();
      final command = ChangeCurseCommand(
          1, "Zealot", "Zealot"); // Empty string for monster deck
      final initialCurseCount =
          gameState.modifierDeck.getRemovable("curse").value;

      // Act
      command.execute();

      // Assert
      final finalCurseCount =
          gameState.modifierDeck.getRemovable("curse").value;
      expect(finalCurseCount, initialCurseCount + 1);
      checkSaveState();
    });

    test('should remove a curse card from the monster deck', () {
      // Arrange
      final gameState = getIt<GameState>();
      ChangeCurseCommand(1, "Zealot", "Zealot").execute(); // Add a curse first
      final initialCurseCount =
          gameState.modifierDeck.getRemovable("curse").value;
      final command = ChangeCurseCommand(-1, "Zealot", "Zealot");

      // Act
      command.execute();

      // Assert
      final finalCurseCount =
          gameState.modifierDeck.getRemovable("curse").value;
      expect(finalCurseCount, initialCurseCount - 1);
      checkSaveState();
    });

    test('describe should return correct string for adding curse', () {
      // Arrange
      final command = ChangeCurseCommand(1, 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Add a Curse');
      checkSaveState();
    });

    test('describe should return correct string for removing curse', () {
      // Arrange
      final command = ChangeCurseCommand(-1, 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Remove a Curse');
      checkSaveState();
    });

    test('describe should return correct string for monster deck', () {
      // Arrange
      final command = ChangeCurseCommand(1, "Zealot", "Zealot");

      // Act & Assert
      expect(command.describe(), 'Add a Curse');
      checkSaveState();
    });
  });
}
