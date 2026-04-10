import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_reveal_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('AMDRevealCommand', () {
    test('should set revealedCount on the main modifier deck', () {
      final command = AMDRevealCommand(amount: 2, name: 'Monsters', gameState: getIt<GameState>());
      command.execute();
      expect(getIt<GameState>().modifierDeck.revealedCount.value, 2);
      checkSaveState();
    });

    test('should set revealedCount to zero when amount is 0', () {
      AMDRevealCommand(amount: 3, name: 'Monsters', gameState: getIt<GameState>()).execute();
      AMDRevealCommand(amount: 0, name: 'Monsters', gameState: getIt<GameState>()).execute();
      expect(getIt<GameState>().modifierDeck.revealedCount.value, 0);
    });

    test('describe should include the amount', () {
      final command = AMDRevealCommand(amount: 3, name: 'Monsters', gameState: getIt<GameState>());
      expect(command.describe(), 'Reveal 3 modifier cards');
    });
  });
}
