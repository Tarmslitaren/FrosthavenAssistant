import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_loot_card_command.dart';
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
    getIt<GameState>().clearList();
    // A scenario is needed to initialize the loot deck
    SetCampaignCommand("Frosthaven").execute();
    SetScenarioCommand('#0 Howling in the Snow', false).execute();
  });

  group('AddLootCardCommand', () {
    test('should add a specified loot card to the deck', () {
      // Arrange
      final command = AddLootCardCommand('lumber');
      final lootDeck = getIt<GameState>().lootDeck;
      final initialCardCount = lootDeck.drawPile.size();

      // Act
      command.execute();

      // Assert
      expect(lootDeck.drawPile.size(), initialCardCount + 1);
      checkSaveState();
    });

    test('describe should return the correct string', () {
      // Arrange
      final command = AddLootCardCommand('hides');

      // Act & Assert
      expect(command.describe(), 'Add hides Loot Card');
    });
  });
}
