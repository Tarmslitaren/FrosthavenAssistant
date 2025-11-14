import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('ChangeXPCommand', () {
    test('should increase a character\'s XP', () {
      // Arrange
      final initialXp = character.characterState.xp.value;
      final command = ChangeXPCommand(10, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.xp.value, initialXp + 10);
    });

    test('should decrease a character\'s XP', () {
      // Arrange
      ChangeXPCommand(20, character.id, character.id).execute();
      final initialXp = character.characterState.xp.value;
      final command = ChangeXPCommand(-5, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.xp.value, initialXp - 5);
    });

    test('should not decrease XP below 0', () {
      // Arrange
      final command = ChangeXPCommand(-100, character.id, character.id);

      // Act
      command.execute();

      // Assert
      expect(character.characterState.xp.value, 0);
    });

    test('undo should not revert XP change (as currently implemented)', () {
      // Arrange
      final initialXp = character.characterState.xp.value;
      final command = ChangeXPCommand(10, character.id, character.id);
      command.execute();

      // Act
      command.undo();

      // Assert
      // The undo method is incomplete and does not revert the xp.
      // This test verifies the current behavior.
      expect(character.characterState.xp.value, initialXp + 10);
    });

    test('describe should return correct string for increasing XP', () {
      final command = ChangeXPCommand(10, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Increase Blinkblade's xp by 10");
    });

    test('describe should return correct string for decreasing XP', () {
      final command = ChangeXPCommand(-5, 'Blinkblade', 'Blinkblade');
      expect(command.describe(), "Decrease Blinkblade's xp by 5");
    });
  });
}
