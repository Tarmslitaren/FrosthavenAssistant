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
      DrawModifierCardCommand('').execute();
      final deck = getIt<GameState>().modifierDeck;
      final drawBefore = deck.drawPile.size();
      final discardBefore = deck.discardPile.size();

      ReturnModifierCardCommand('').execute();

      expect(deck.drawPile.size(), drawBefore + 1);
      expect(deck.discardPile.size(), discardBefore - 1);
      checkSaveState();
    });

    test('describe returns correct string', () {
      final command = ReturnModifierCardCommand('');
      expect(command.describe(), 'Return modifier card to top');
    });
  });
}
