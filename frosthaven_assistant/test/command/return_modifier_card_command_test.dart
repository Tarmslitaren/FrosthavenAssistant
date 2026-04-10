import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/return_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('ReturnModifierCardCommand', () {
    test('should move top discard card back to draw pile', () {
      DrawModifierCardCommand('', gameState: getIt<GameState>()).execute();
      final deck = getIt<GameState>().modifierDeck;
      final drawBefore = deck.drawPileSize;
      final discardBefore = deck.discardPileSize;

      ReturnModifierCardCommand('').execute();

      expect(deck.drawPileSize, drawBefore + 1);
      expect(deck.discardPileSize, discardBefore - 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      final command = ReturnModifierCardCommand('');
      expect(command.describe(), 'Return modifier card to top');
    });
  });
}
