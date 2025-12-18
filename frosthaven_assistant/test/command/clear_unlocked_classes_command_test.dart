import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/clear_unlocked_classes_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {});

  group('ClearUnlockedClassesCommand', () {
    test('should clear unlocked classes', () {
      // Arrange
      AddCharacterCommand("Banner Spear", "Frosthaven", "Banny", 1)
          .execute(); //test data BS is hidden class

      final gameState = getIt<GameState>();
      expect(gameState.unlockedClasses, isNotEmpty,
          reason: "Prerequisite: A class should be unlocked.");

      final command = ClearUnlockedClassesCommand();

      // Act
      command.execute();

      // Assert
      expect(gameState.unlockedClasses, isEmpty);
    });

    test('describe should return correct string', () {
      // Arrange
      final command = ClearUnlockedClassesCommand();

      // Act & Assert
      expect(command.describe(), 'clear unlocked classes');
    });
  });
}
