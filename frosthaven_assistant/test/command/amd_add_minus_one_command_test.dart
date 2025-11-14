import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_add_minus_one_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('AmdAddMinusOneCommand', () {
    test('should add a minus one card to a character deck', () {
      // Arrange
      final command = AmdAddMinusOneCommand(character.id);
      final modifierDeck = character.characterState.modifierDeck;
      int initialCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          initialCount++;
        }
      });

      // Act
      command.execute();

      // Assert
      int finalCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          finalCount++;
        }
      });
      expect(finalCount, initialCount + 1);
    });

    test('should add a minus one card to the monster deck', () {
      // Arrange
      final command = AmdAddMinusOneCommand('');
      final modifierDeck = getIt<GameState>().modifierDeck;
      int initialCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          initialCount++;
        }
      });

      // Act
      command.execute();

      // Assert
      int finalCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          finalCount++;
        }
      });
      expect(finalCount, initialCount + 1);
    });

    test('should add a minus one card to the allies deck', () {
      // Arrange
      final command = AmdAddMinusOneCommand('allies');
      final modifierDeck = getIt<GameState>().modifierDeckAllies;
      int initialCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          initialCount++;
        }
      });

      // Act
      command.execute();

      // Assert
      int finalCount = 0;
      modifierDeck.drawPile.getList().forEach((element) {
        if (element.gfx == 'minus1') {
          finalCount++;
        }
      });
      expect(finalCount, initialCount + 1);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AmdAddMinusOneCommand('Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Add minus one');
    });
  });
}
