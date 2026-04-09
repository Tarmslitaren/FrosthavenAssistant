import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_auto_level_adjust_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('SetAutoLevelAdjustCommand', () {
    test('should turn auto level adjust on', () {
      final command = SetAutoLevelAdjustCommand(true);
      command.execute();
      expect(getIt<GameState>().autoScenarioLevel.value, isTrue);
      checkSaveState();
    });

    test('should turn auto level adjust off', () {
      SetAutoLevelAdjustCommand(true).execute();
      final command = SetAutoLevelAdjustCommand(false);
      command.execute();
      expect(getIt<GameState>().autoScenarioLevel.value, isFalse);
      checkSaveState();
    });

    test('describe should say "on" when enabled', () {
      final command = SetAutoLevelAdjustCommand(true);
      expect(command.describe(), 'turn automatic level updated on');
    });

    test('describe should say "off" when disabled', () {
      final command = SetAutoLevelAdjustCommand(false);
      expect(command.describe(), 'turn automatic level updated off');
    });
  });
}
