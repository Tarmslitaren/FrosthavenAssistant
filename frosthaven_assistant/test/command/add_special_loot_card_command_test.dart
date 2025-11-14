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
    SetScenarioCommand('#0 Howling in the Snow', false).execute();
  });

  group('AddSpecialLootCardCommand', () {
    test('should add special loot card 1418', () {
      // Arrange
      final command = AddSpecialLootCardCommand(1418);
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPile.size();

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPile.size(), initialCardCount + 1);
      final card = lootDeck.drawPile
          .getList()
          .firstWhereOrNull((card) => card.id == 1418);
      expect(card?.gfx, 'special 1418');
      checkSaveState();
    });

    test('should add special loot card 1419', () {
      // Arrange
      final command = AddSpecialLootCardCommand(1419);
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPile.size();

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPile.size(), initialCardCount + 1);
      final card = lootDeck.drawPile
          .getList()
          .firstWhereOrNull((card) => card.id == 1419);
      expect(card?.gfx, 'special 1419');
      checkSaveState();
    });

    test('should not add other cards', () {
      // Arrange
      final command = AddSpecialLootCardCommand(9999);
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPile.size();

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPile.size(), initialCardCount);
      // Since no change is expected, we don't call checkSaveState()
    });

    test('undo should not do anything (as currently implemented)', () {
      // Arrange
      final command = AddSpecialLootCardCommand(1418);
      final lootDeck = getIt<GameState>().lootDeck;
      command.execute();
      final cardCountAfterExecute = lootDeck.drawPile.size();

      // Act
      command.undo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(lootDeck.drawPile.size(), cardCountAfterExecute);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AddSpecialLootCardCommand(1418);

      // Act & Assert
      expect(command.describe(), 'Add Special loot card 1418');
    });
  });
}
