import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_amd_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/return_removed_amd_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('RemoveAMDCardCommand', () {
    test('should move card from discard to removed pile', () {
      DrawModifierCardCommand('', gameState: getIt<GameState>()).execute();
      final deck = getIt<GameState>().modifierDeck;
      final discardBefore = deck.discardPileSize;
      final removedBefore = deck.removedPileSize;

      RemoveAMDCardCommand(
        index: 0,
        name: '',
        gameState: getIt<GameState>(),
      ).execute();

      expect(deck.discardPileSize, discardBefore - 1);
      expect(deck.removedPileSize, removedBefore + 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      final command = RemoveAMDCardCommand(
        index: 0,
        name: '',
        gameState: getIt<GameState>(),
      );
      expect(command.describe(), 'Remove amd card');
    });
  });

  group('ReturnRemovedAMDCardCommand', () {
    test('should move card from removed pile back to discard', () {
      DrawModifierCardCommand('', gameState: getIt<GameState>()).execute();
      RemoveAMDCardCommand(
        index: 0,
        name: '',
        gameState: getIt<GameState>(),
      ).execute();
      final deck = getIt<GameState>().modifierDeck;
      final discardBefore = deck.discardPileSize;
      final removedBefore = deck.removedPileSize;

      ReturnRemovedAMDCardCommand(
        index: 0,
        name: '',
        gameState: getIt<GameState>(),
      ).execute();

      expect(deck.removedPileSize, removedBefore - 1);
      expect(deck.discardPileSize, discardBefore + 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      final command = ReturnRemovedAMDCardCommand(
        index: 0,
        name: '',
        gameState: getIt<GameState>(),
      );
      expect(command.describe(), 'Return removed amd card');
    });
  });
}
