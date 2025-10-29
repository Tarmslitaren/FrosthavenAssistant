import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/activate_monster_type_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
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
    });

    test('describe should return correct string for activation', () {
      // Arrange
      final command = ActivateMonsterTypeCommand('Zealot', true);

      // Act & Assert
      expect(command.describe(), 'Activate Zealot');
    });

    test('describe should return correct string for deactivation', () {
      // Arrange
      final command = ActivateMonsterTypeCommand('Zealot', false);

      // Act & Assert
      expect(command.describe(), 'Deactivate Zealot');
    });
  });
}
