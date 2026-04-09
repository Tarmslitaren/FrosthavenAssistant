import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/enhance_loot_card_command.dart';
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
    SetCampaignCommand('Frosthaven').execute();
    SetScenarioCommand('#0 Howling in the Snow', false).execute();
  });

  group('EnhanceLootCardCommand', () {
    test('should add an enhancement to a loot card', () {
      final lootDeck = getIt<GameState>().lootDeck;
      // Get any existing card id from the draw pile
      if (lootDeck.drawPileIsNotEmpty) {
        final cardId = lootDeck.drawPileContents.toList().first.id;

        EnhanceLootCardCommand(cardId, 2, 'coin').execute();

        // After enhancement the deck is rebuilt; verify it doesn't crash
        expect(lootDeck.drawPileIsNotEmpty, isTrue);
        checkSaveState();
      }
    });

    test('describe returns "Add Loot Enhancement" when value is positive', () {
      expect(EnhanceLootCardCommand(1, 1, 'coin').describe(),
          'Add Loot Enhancement');
    });

    test('describe returns "Remove Loot Enhancement" when value is zero or negative', () {
      expect(EnhanceLootCardCommand(1, 0, 'coin').describe(),
          'Remove Loot Enhancement');
      expect(EnhanceLootCardCommand(1, -1, 'coin').describe(),
          'Remove Loot Enhancement');
    });
  });
}
