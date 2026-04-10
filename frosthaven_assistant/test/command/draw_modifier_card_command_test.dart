import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('DrawModifierCardCommand', () {
    test('should move a card from draw pile to discard pile', () {
      final deck = getIt<GameState>().modifierDeck;
      final drawBefore = deck.drawPileSize;
      final discardBefore = deck.discardPileSize;

      DrawModifierCardCommand('', gameState: getIt<GameState>()).execute();

      expect(deck.drawPileSize, drawBefore - 1);
      expect(deck.discardPileSize, discardBefore + 1);
      checkSaveState();
    });

    test('describe with empty name returns monster string', () {
      final command = DrawModifierCardCommand('', gameState: getIt<GameState>());
      expect(command.describe(), 'Draw monster modifier card');
    });

    test('describe with non-empty name includes name', () {
      final command = DrawModifierCardCommand('Blinkblade', gameState: getIt<GameState>());
      expect(command.describe(), 'Draw Blinkblade modifier card');
    });
  });
}
