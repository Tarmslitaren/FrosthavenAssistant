import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_faction_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;
  late String factionCardId;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
    // Get a valid faction card ID to use in tests
    factionCardId = GameMethods.getFactionCards('Military').first.gfx;
  });

  group('AddFactionCardCommand', () {
    test('should add a faction card to a character deck', () {
      // Arrange
      final command = AddFactionCardCommand(character.id, factionCardId, true);
      final modifierDeck = character.characterState.modifierDeck;

      // Act
      command.execute();

      // Assert
      expect(modifierDeck.hasCard(factionCardId), isTrue);
    });

    test('should remove a faction card from a character deck', () {
      // Arrange
      final modifierDeck = character.characterState.modifierDeck;
      // Add the card first
      AddFactionCardCommand(character.id, factionCardId, true).execute();
      expect(modifierDeck.hasCard(factionCardId), isTrue);

      final command = AddFactionCardCommand(character.id, factionCardId, false);

      // Act
      command.execute();

      // Assert
      expect(modifierDeck.hasCard(factionCardId), isFalse);
    });

    test('undo should not do anything (as currently implemented)', () {
      // Arrange
      final command = AddFactionCardCommand(character.id, factionCardId, true);
      final modifierDeck = character.characterState.modifierDeck;
      command.execute();
      final hasCardAfterExecute = modifierDeck.hasCard(factionCardId);

      // Act
      command.undo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(modifierDeck.hasCard(factionCardId), hasCardAfterExecute);
    });

    test('describe should return correct string for adding a card', () {
      // Arrange
      final command = AddFactionCardCommand('Blinkblade', factionCardId, true);

      // Act & Assert
      expect(command.describe(), 'Blinkblade add faction card');
    });

    test('describe should return correct string for removing a card', () {
      // Arrange
      final command = AddFactionCardCommand('Blinkblade', factionCardId, false);

      // Act & Assert
      expect(command.describe(), 'Blinkblade remove faction card');
    });
  });
}
