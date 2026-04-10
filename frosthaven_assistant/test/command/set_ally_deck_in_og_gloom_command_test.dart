import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_ally_deck_in_og_gloom_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('SetAllyDeckInOgGloomCommand', () {
    test('should set allyDeckInOGGloom to false', () {
      SetAllyDeckInOgGloomCommand(false, gameState: getIt<GameState>()).execute();
      expect(getIt<GameState>().allyDeckInOGGloom.value, isFalse);
      checkSaveState();
    });

    test('should set allyDeckInOGGloom to true', () {
      SetAllyDeckInOgGloomCommand(false, gameState: getIt<GameState>()).execute();
      SetAllyDeckInOgGloomCommand(true, gameState: getIt<GameState>()).execute();
      expect(getIt<GameState>().allyDeckInOGGloom.value, isTrue);
      checkSaveState();
    });

    test('describe when false returns no-ally string', () {
      final command = SetAllyDeckInOgGloomCommand(false, gameState: getIt<GameState>());
      expect(command.describe(),
          'No ally deck in 1st edition Gloomhaven campaigns');
    });

    test('describe when true returns use-ally string', () {
      final command = SetAllyDeckInOgGloomCommand(true, gameState: getIt<GameState>());
      expect(command.describe(),
          'Use Ally Deck in 1st edition Gloomhaven Campaigns');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(SetAllyDeckInOgGloomCommand(true, gameState: getIt<GameState>()));
      expect(() => gs.undo(), returnsNormally);
    });
  });
}
