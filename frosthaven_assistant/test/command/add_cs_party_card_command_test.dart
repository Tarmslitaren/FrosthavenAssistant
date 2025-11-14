import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_cs_party_card_command.dart';
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
    // Using a non-CS character is fine for testing the command's logic
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('AddCSPartyCardCommand', () {
    test('should add a CS party card to a character deck', () {
      // Arrange
      final command = AddCSPartyCardCommand(character.id, 1);
      final modifierDeck = character.characterState.modifierDeck;
      final initialCardCount = modifierDeck.cardCount.value;

      // Act
      command.execute();

      // Assert
      final finalCardCount = modifierDeck.cardCount.value;
      expect(finalCardCount, initialCardCount + 1);
      expect(modifierDeck.hasCard('party/1'), isTrue);
      checkSaveState();
    });

    test('should add a different CS party card to a character deck', () {
      // Arrange
      final command = AddCSPartyCardCommand(character.id, 2);
      final modifierDeck = character.characterState.modifierDeck;
      final initialCardCount = modifierDeck.cardCount.value;

      // Act
      command.execute();

      // Assert
      final finalCardCount = modifierDeck.cardCount.value;
      expect(finalCardCount, initialCardCount + 1);
      expect(modifierDeck.hasCard('party/2'), isTrue);
      checkSaveState();
    });

    test('undo should not do anything (as currently implemented)', () {
      // Arrange
      final command = AddCSPartyCardCommand(character.id, 1);
      final modifierDeck = character.characterState.modifierDeck;
      command.execute();
      final cardCountAfterExecute = modifierDeck.cardCount.value;

      // Act
      command.undo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(modifierDeck.cardCount.value, cardCountAfterExecute);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AddCSPartyCardCommand('Blinkblade', 1);

      // Act & Assert
      expect(command.describe(), 'Blinkblade add party card 1');
    });
  });
}
