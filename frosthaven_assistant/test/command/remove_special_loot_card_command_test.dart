// ignore_for_file: no-magic-number

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove__special_loot_card_command.dart';
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
    SetScenarioCommand('#0 Howling in the Snow', false,
            gameState: getIt<GameState>())
        .execute();
  });

  group('RemoveSpecialLootCardCommand', () {
    test('should remove special card 1418 from draw pile', () {
      AddSpecialLootCardCommand(1418, gameState: getIt<GameState>()).execute();
      final lootDeck = getIt<GameState>().lootDeck;
      expect(lootDeck.hasCard1418, isTrue);

      RemoveSpecialLootCardCommand(1418, gameState: getIt<GameState>())
          .execute();

      expect(lootDeck.hasCard1418, isFalse);
      checkSaveState();
    });

    test('should remove special card 1419 from draw pile', () {
      AddSpecialLootCardCommand(1419, gameState: getIt<GameState>()).execute();
      final lootDeck = getIt<GameState>().lootDeck;
      expect(lootDeck.hasCard1419, isTrue);

      RemoveSpecialLootCardCommand(1419, gameState: getIt<GameState>())
          .execute();

      expect(lootDeck.hasCard1419, isFalse);
      checkSaveState();
    });

    test('should do nothing for unknown card nr', () {
      final lootDeck = getIt<GameState>().lootDeck;
      final countBefore = lootDeck.drawPileSize;

      RemoveSpecialLootCardCommand(9999, gameState: getIt<GameState>())
          .execute();

      expect(lootDeck.drawPileSize, countBefore);
    });

    test('describe includes the card number', () {
      final command =
          RemoveSpecialLootCardCommand(1418, gameState: getIt<GameState>());
      expect(command.describe(), 'Remove Special loot card 1418');
    });
  });
}
