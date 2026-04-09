import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_solo_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('SetSoloCommand', () {
    test('should set solo to true', () {
      final command = SetSoloCommand(true);
      command.execute();
      expect(getIt<GameState>().solo.value, isTrue);
      checkSaveState();
    });

    test('should set solo to false', () {
      SetSoloCommand(true).execute();
      final command = SetSoloCommand(false);
      command.execute();
      expect(getIt<GameState>().solo.value, isFalse);
      checkSaveState();
    });

    test('describe should return solo recommendation string when true', () {
      final command = SetSoloCommand(true);
      expect(command.describe(), 'set solo level recommendation');
    });

    test('describe should return regular recommendation string when false', () {
      final command = SetSoloCommand(false);
      expect(command.describe(), 'set regular level recommendation');
    });
  });
}
