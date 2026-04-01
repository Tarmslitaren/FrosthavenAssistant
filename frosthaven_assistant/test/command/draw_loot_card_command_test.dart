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
      expect(lootDeck.drawPile.isNotEmpty, isTrue,
          reason: 'Frosthaven custom scenario should have a loot deck');
      final drawBefore = lootDeck.drawPile.size();
      final discardBefore = lootDeck.discardPile.size();

      DrawLootCardCommand().execute();

      expect(lootDeck.drawPile.size(), drawBefore - 1);
      expect(lootDeck.discardPile.size(), discardBefore + 1);
      checkSaveState();
    });

    test('should do nothing when draw pile is empty', () {
      final lootDeck = getIt<GameState>().lootDeck;
      final totalCards =
          lootDeck.drawPile.size() + lootDeck.discardPile.size();
      // Drain draw pile
      while (lootDeck.drawPile.isNotEmpty) {
        DrawLootCardCommand().execute();
      }
      DrawLootCardCommand().execute(); // should not throw
      expect(lootDeck.drawPile.size() + lootDeck.discardPile.size(),
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
      final drawBefore = lootDeck.drawPile.size();
      final discardBefore = lootDeck.discardPile.size();

      ReturnLootCardCommand(true).execute();

      expect(lootDeck.drawPile.size(), drawBefore + 1);
      expect(lootDeck.discardPile.size(), discardBefore - 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      expect(ReturnLootCardCommand(true).describe(), 'Return loot card');
    });
  });
}
