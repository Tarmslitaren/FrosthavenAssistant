import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  group('AddMonsterCommand', () {
    test('should add a monster to the game', () {
      // Arrange
      final command = AddMonsterCommand("Ancient Artillery (FH)", 2, false);

      // Act
      command.execute();

      // Assert
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      expect(getIt<GameState>().currentList, contains(monster));
      expect(monster.id, "Ancient Artillery (FH)");
      expect(monster.level.value, 2);
      expect(monster.isAlly, isFalse);
    });

    test('should add an allied monster', () {
      // Arrange
      final command = AddMonsterCommand("Ancient Artillery (FH)", 2, true);

      // Act
      command.execute();

      // Assert
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      expect(monster.isAlly, isTrue);
    });

    test('should use game level if monster level is null', () {
      // Arrange
      SetLevelCommand(3, null).execute();
      final command = AddMonsterCommand("Ancient Artillery (FH)", null, false);

      // Act
      command.execute();

      // Assert
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      expect(monster.level.value, 3);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = AddMonsterCommand("Ancient Artillery (FH)", 2, false);

      // Act & Assert
      expect(command.describe(), 'Add Ancient Artillery');
    });
  });
}
