import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_loot_owner_command.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1, gameState: getIt<GameState>()).execute();
    SetCampaignCommand('Frosthaven').execute();
    SetScenarioCommand('custom', false, gameState: getIt<GameState>()).execute();
    DrawLootCardCommand(gameState: getIt<GameState>()).execute();
  });

  group('SetLootOwnerCommand', () {
    test('should set owner on the loot card', () {
      final lootDeck = getIt<GameState>().lootDeck;
      final card = lootDeck.discardPileTop;
      expect(card.owner, isEmpty);

      SetLootOwnerCommand('Blinkblade', card).execute();

      expect(card.owner, 'Blinkblade');
      checkSaveState();
    });

    test('describe returns correct string', () {
      final lootDeck = getIt<GameState>().lootDeck;
      final card = lootDeck.discardPileTop;
      final command = SetLootOwnerCommand('Blinkblade', card);
      expect(command.describe(), 'Set loot card owner');
    });
  });
}
