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
      SetAllyDeckInOgGloomCommand(false).execute();
      expect(getIt<GameState>().allyDeckInOGGloom.value, isFalse);
      checkSaveState();
    });

    test('should set allyDeckInOGGloom to true', () {
      SetAllyDeckInOgGloomCommand(false).execute();
      SetAllyDeckInOgGloomCommand(true).execute();
      expect(getIt<GameState>().allyDeckInOGGloom.value, isTrue);
      checkSaveState();
    });

    test('describe when false returns no-ally string', () {
      final command = SetAllyDeckInOgGloomCommand(false);
      expect(command.describe(),
          'No ally deck in 1st edition Gloomhaven campaigns');
    });

    test('describe when true returns use-ally string', () {
      final command = SetAllyDeckInOgGloomCommand(true);
      expect(command.describe(),
          'Use Ally Deck in 1st edition Gloomhaven Campaigns');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(SetAllyDeckInOgGloomCommand(true));
      expect(() => gs.undo(), returnsNormally);
    });
  });
}
