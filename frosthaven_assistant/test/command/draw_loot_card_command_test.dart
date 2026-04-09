import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/return_loot_card_command.dart';
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
    // Frosthaven custom scenario creates a loot deck
    SetCampaignCommand('Frosthaven').execute();
    SetScenarioCommand('custom', false).execute();
  });

  group('DrawLootCardCommand', () {
    test('should move a card from draw pile to discard pile', () {
      final lootDeck = getIt<GameState>().lootDeck;
      expect(lootDeck.drawPileIsNotEmpty, isTrue,
          reason: 'Frosthaven custom scenario should have a loot deck');
      final drawBefore = lootDeck.drawPileSize;
      final discardBefore = lootDeck.discardPileSize;

      DrawLootCardCommand().execute();

      expect(lootDeck.drawPileSize, drawBefore - 1);
      expect(lootDeck.discardPileSize, discardBefore + 1);
      checkSaveState();
    });

    test('should do nothing when draw pile is empty', () {
      final lootDeck = getIt<GameState>().lootDeck;
      final totalCards =
          lootDeck.drawPileSize + lootDeck.discardPileSize;
      // Drain draw pile
      while (lootDeck.drawPileIsNotEmpty) {
        DrawLootCardCommand().execute();
      }
      DrawLootCardCommand().execute(); // should not throw
      expect(lootDeck.drawPileSize + lootDeck.discardPileSize,
          totalCards);
    });

    test('describe returns correct string', () {
      expect(DrawLootCardCommand().describe(), 'Draw loot card');
    });
  });

  group('ReturnLootCardCommand', () {
    test('should return discard card to top of draw pile', () {
      DrawLootCardCommand().execute();
      final lootDeck = getIt<GameState>().lootDeck;
      final drawBefore = lootDeck.drawPileSize;
      final discardBefore = lootDeck.discardPileSize;

      ReturnLootCardCommand(true).execute();

      expect(lootDeck.drawPileSize, drawBefore + 1);
      expect(lootDeck.discardPileSize, discardBefore - 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      expect(ReturnLootCardCommand(true).describe(), 'Return loot card');
    });
  });
}
