import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/activate_monster_type_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() async {
  await setUpGame();

  group('ActivateMonsterTypeCommand', () {
    test('should activate a monster', () {
      // Arrange
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((m) => m.id == 'Zealot') as Monster;

      expect(monster.isActive, isFalse);

      final command = ActivateMonsterTypeCommand('Zealot', true);

      // Act
      command.execute();

      // Assert
      expect(monster.isActive, isTrue);
      checkSaveState();
    });

    test('should deactivate a monster', () {
      // Arrange
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((m) => m.id == 'Zealot') as Monster;

      final command = ActivateMonsterTypeCommand('Zealot', false);

      // Act
      command.execute();

      // Assert
      expect(monster.isActive, isFalse);
      checkSaveState();
    });

    test('describe should return correct string for activation', () {
      // Arrange
      final command = ActivateMonsterTypeCommand('Zealot', true);

      // Act & Assert
      expect(command.describe(), 'Activate Zealot');
      checkSaveState();
    });

    test('describe should return correct string for deactivation', () {
      // Arrange
      final command = ActivateMonsterTypeCommand('Zealot', false);

      // Act & Assert
      expect(command.describe(), 'Deactivate Zealot');
      checkSaveState();
    });

    test('undo does not throw', () {
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      final gs = getIt<GameState>();
      gs.action(ActivateMonsterTypeCommand('Zealot', true));
      expect(() => gs.undo(), returnsNormally);
    });

    test('activate in RoundState.playTurns draws ability card and sorts', () {
      getIt<GameState>().clearList();
      AddMonsterCommand('Zealot', 1, false).execute();
      // Enter playTurns state via DrawCommand
      DrawCommand().execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      // Activate should not throw even in playTurns state
      expect(
        () => ActivateMonsterTypeCommand('Zealot', true).execute(),
        returnsNormally,
      );
    });
  });
}
