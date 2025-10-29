import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_bless_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

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

  group('ChangeBlessCommand', () {
    test('should add a bless card to a character deck', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      final command = ChangeBlessCommand(1, character.id, character.id);
      final initialBlessCount =
          character.characterState.modifierDeck.getRemovable("bless").value;

      // Act
      command.execute();

      // Assert
      final finalBlessCount =
          character.characterState.modifierDeck.getRemovable("bless").value;
      expect(finalBlessCount, initialBlessCount + 1);
    });

    test('should remove a bless card from a character deck', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      ChangeBlessCommand(1, character.id, character.id)
          .execute(); // Add a bless first
      final initialBlessCount =
          character.characterState.modifierDeck.getRemovable("bless").value;
      final command = ChangeBlessCommand(-1, character.id, character.id);

      // Act
      command.execute();

      // Assert
      final finalBlessCount =
          character.characterState.modifierDeck.getRemovable("bless").value;
      expect(finalBlessCount, initialBlessCount - 1);
    });

    test('should add a bless card to the monster deck', () {
      // Arrange
      final gameState = getIt<GameState>();
      final command = ChangeBlessCommand(
          1, "Zealot", "Zealot"); // Empty string for monster deck
      final initialBlessCount =
          gameState.modifierDeck.getRemovable("bless").value;

      // Act
      command.execute();

      // Assert
      final finalBlessCount =
          gameState.modifierDeck.getRemovable("bless").value;
      expect(finalBlessCount, initialBlessCount + 1);
    });

    test('should remove a bless card from the monster deck', () {
      // Arrange
      final gameState = getIt<GameState>();
      ChangeBlessCommand(1, "Zealot", "Zealot").execute(); // Add a bless first
      final initialBlessCount =
          gameState.modifierDeck.getRemovable("bless").value;
      final command = ChangeBlessCommand(-1, "Zealot", "Zealot");

      // Act
      command.execute();

      // Assert
      final finalBlessCount =
          gameState.modifierDeck.getRemovable("bless").value;
      expect(finalBlessCount, initialBlessCount - 1);
    });

    test('describe should return correct string for adding bless', () {
      // Arrange
      final command = ChangeBlessCommand(1, 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Add a Bless');
    });

    test('describe should return correct string for removing bless', () {
      // Arrange
      final command = ChangeBlessCommand(-1, 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Remove a Bless');
    });

    test('describe should return correct string for monster deck', () {
      // Arrange
      final command = ChangeBlessCommand(1, "Zealot", "Zealot");

      // Act & Assert
      expect(command.describe(), 'Add a Bless');
    });
  });
}
