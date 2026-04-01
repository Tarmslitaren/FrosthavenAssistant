import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/hide_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/commands/show_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('ShowAllyDeckCommand', () {
    test('should set showAllyDeck to true', () {
      HideAllyDeckCommand().execute();
      expect(getIt<GameState>().showAllyDeck.value, isFalse);

      ShowAllyDeckCommand().execute();

      expect(getIt<GameState>().showAllyDeck.value, isTrue);
      checkSaveState();
    });

    test('describe should return correct string', () {
      expect(ShowAllyDeckCommand().describe(), 'Show Ally Deck');
    });
  });

  group('HideAllyDeckCommand', () {
    test('should set showAllyDeck to false', () {
      ShowAllyDeckCommand().execute();
      expect(getIt<GameState>().showAllyDeck.value, isTrue);

      HideAllyDeckCommand().execute();

      expect(getIt<GameState>().showAllyDeck.value, isFalse);
      checkSaveState();
    });

    test('describe should return correct string', () {
      expect(HideAllyDeckCommand().describe(), 'Hide Ally Deck');
    });
  });
}
