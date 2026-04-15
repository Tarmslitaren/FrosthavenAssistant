import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    //getIt<GameState>().reset();
    // A scenario is needed to initialize the loot deck
    SetCampaignCommand("Frosthaven").execute();
    SetScenarioCommand('#0 Howling in the Snow', false,
            gameState: getIt<GameState>())
        .execute();
  });

  group('AddSpecialLootCardCommand', () {
    test('should add special loot card 1418', () {
      // Arrange
      final command =
          AddSpecialLootCardCommand(1418, gameState: getIt<GameState>());
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPileSize;

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPileSize, initialCardCount + 1);
      final card =
          lootDeck.drawPileContents.firstWhereOrNull((card) => card.id == 1418);
      expect(card?.gfx, 'special 1418');
      checkSaveState();
    });

    test('should add special loot card 1419', () {
      // Arrange
      final command =
          AddSpecialLootCardCommand(1419, gameState: getIt<GameState>());
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPileSize;

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPileSize, initialCardCount + 1);
      final card =
          lootDeck.drawPileContents.firstWhereOrNull((card) => card.id == 1419);
      expect(card?.gfx, 'special 1419');
      checkSaveState();
    });

    test('should not add other cards', () {
      // Arrange
      final command =
          AddSpecialLootCardCommand(9999, gameState: getIt<GameState>());
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPileSize;

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPileSize, initialCardCount);
      // Since no change is expected, we don't call checkSaveState()
    });

    test('undo should not do anything (as currently implemented)', () {
      // Arrange
      final command =
          AddSpecialLootCardCommand(1418, gameState: getIt<GameState>());
      final lootDeck = getIt<GameState>().lootDeck;
      command.execute();
      final cardCountAfterExecute = lootDeck.drawPileSize;

      // Act
      command.onUndo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(lootDeck.drawPileSize, cardCountAfterExecute);
    });

    test('describe should return correct string', () {
      // Arrange
      final command =
          AddSpecialLootCardCommand(1418, gameState: getIt<GameState>());

      // Act & Assert
      expect(command.describe(), 'Add Special loot card 1418');
    });
  });
}
