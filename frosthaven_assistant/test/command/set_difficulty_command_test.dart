import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/set_difficulty_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  group('SetDifficultyCommand', () {
    test('should set difficulty to given value', () {
      final command = SetDifficultyCommand(2, gameState: getIt<GameState>());
      command.execute();
      expect(getIt<GameState>().difficulty.value, 2);
      checkSaveState();
    });

    test('should set difficulty to negative value', () {
      final command = SetDifficultyCommand(-1, gameState: getIt<GameState>());
      command.execute();
      expect(getIt<GameState>().difficulty.value, -1);
      checkSaveState();
    });

    test('describe should include difficulty level', () {
      final command = SetDifficultyCommand(3, gameState: getIt<GameState>());
      expect(command.describe(), 'set difficulty level to 3');
    });
  });
}
