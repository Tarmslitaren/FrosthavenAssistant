import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_minus_1_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

int getMinusOnes(ModifierDeck deck) {
  int count = 0;
  for (var item in deck.drawPile.getList()) {
    if (item.gfx == "minus1") {
      count++;
    }
  }
  return count;
}

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    //getIt<GameState>().reset();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('AMDRemoveMinus1Command', () {
    test('should remove a minus one card from a character deck', () {
      // Arrange
      final modifierDeck = character.characterState.modifierDeck;
      int initialCount = getMinusOnes(modifierDeck);
      expect(initialCount, 5);

      final command = AMDRemoveMinus1Command(character.id);

      // Act
      command.execute();

      // Assert
      final finalCount = getMinusOnes(modifierDeck);
      expect(finalCount, initialCount - 1);
    });

    test('should remove a minus one card from a character deck', () {
      // Arrange
      final modifierDeck = character.characterState.modifierDeck;
      AmdAddMinusOneCommand(character.id).execute(); // Add one first
      int initialCount = getMinusOnes(modifierDeck);
      expect(initialCount, 6);

      final command = AMDRemoveMinus1Command(character.id);

      // Act
      command.execute();

      // Assert
      final finalCount = getMinusOnes(modifierDeck);
      expect(finalCount, initialCount - 1);
    });

    test('should remove a minus one card from a character deck', () {
      // Arrange
      final modifierDeck = character.characterState.modifierDeck;
      AmdAddMinusOneCommand(character.id).execute(); // Add one first
      int initialCount = getMinusOnes(modifierDeck);
      expect(initialCount, 6);

      final command = AMDRemoveMinus1Command(character.id);

      // Act
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();
      command.execute();

      // Assert
      final finalCount = getMinusOnes(modifierDeck);
      expect(finalCount, 0);
    });

    test('should remove a minus one card from the monster deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeck;
      //AmdAddMinusOneCommand('').execute(); // Add one first
      final initialCount = getMinusOnes(modifierDeck);
      final command = AMDRemoveMinus1Command('');

      // Act
      command.execute();

      // Assert
      final finalCount = getMinusOnes(modifierDeck);
      expect(finalCount, initialCount - 1);
    });

    test('should remove a minus one card from the allies deck', () {
      // Arrange
      final modifierDeck = getIt<GameState>().modifierDeckAllies;
      //AmdAddMinusOneCommand('allies').execute(); // Add one first
      final initialCount = getMinusOnes(modifierDeck);
      final command = AMDRemoveMinus1Command('allies');

      // Act
      command.execute();

      // Assert
      final finalCount = getMinusOnes(modifierDeck);
      expect(finalCount, initialCount - 1);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AMDRemoveMinus1Command('Blinkblade');
      command.execute();

      // Act & Assert
      expect(command.describe(), 'Remove minus one');
    });
  });
}
