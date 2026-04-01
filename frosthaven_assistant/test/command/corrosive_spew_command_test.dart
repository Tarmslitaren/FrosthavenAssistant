import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/corrosive_spew_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('CorrosiveSpewCommand', () {
    test('should set corrosiveSpew to true on main modifier deck', () {
      // CorrosiveSpew targets "Ruinmaw" which falls through to the main deck
      expect(getIt<GameState>().modifierDeck.corrosiveSpew.value, isFalse);

      CorrosiveSpewCommand().execute();

      expect(getIt<GameState>().modifierDeck.corrosiveSpew.value, isTrue);
      checkSaveState();
    });

    test('describe returns correct string', () {
      expect(CorrosiveSpewCommand().describe(), 'Corrosive Spew');
    });
  });
}
