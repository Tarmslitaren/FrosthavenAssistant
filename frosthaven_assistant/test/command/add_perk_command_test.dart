import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

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

  group('AddPerkCommand', () {
    test('should add a perk to a character', () {
      // Arrange
      final perkIndex = 0;
      final command = AddPerkCommand(character.id, perkIndex);
      final initialPerkState = character.characterState.perkList[perkIndex];

      // Act
      command.execute();

      // Assert
      final finalPerkState = character.characterState.perkList[perkIndex];
      expect(initialPerkState, isFalse);
      expect(finalPerkState, isTrue);
      checkSaveState();
    });

    test('should remove an already added perk from a character', () {
      // Arrange
      final perkIndex = 0;
      // Add the perk first
      AddPerkCommand(character.id, perkIndex).execute();
      final initialPerkState = character.characterState.perkList[perkIndex];
      final command = AddPerkCommand(character.id, perkIndex);

      // Act
      command.execute();

      // Assert
      final finalPerkState = character.characterState.perkList[perkIndex];
      expect(initialPerkState, isTrue);
      expect(finalPerkState, isFalse);
      checkSaveState();
    });

    test('undo should not do anything (as currently implemented)', () {
      // Arrange
      final command = AddPerkCommand(character.id, 0);
      command.execute();
      final perkStateAfterExecute = character.characterState.perkList[0];

      // Act
      command.undo();

      // Assert
      // The undo method is empty, so no change is expected.
      expect(character.characterState.perkList[0], perkStateAfterExecute);
    });

    test('describe should return "Remove" when adding a perk (due to bug)', () {
      // Arrange
      // The perk is not yet added, so perkList[index] is false.
      final command = AddPerkCommand(character.id, 0);
      expect(character.characterState.perkList[0], isFalse);

      // Act & Assert
      // The describe method has a bug: it says "Remove" when it should say "Add".
      expect(command.describe(), "Remove '${character.id}' Perk no: 0");
    });

    test('describe should return "Add" when removing a perk (due to bug)', () {
      // Arrange
      // Add the perk first so perkList[index] is true.
      AddPerkCommand(character.id, 0).execute();
      expect(character.characterState.perkList[0], isTrue);
      final command = AddPerkCommand(character.id, 0);

      // Act & Assert
      // The describe method has a bug: it says "Add" when it should say "Remove".
      expect(command.describe(), "Add '${character.id}' Perk no: 0");
    });
  });
}
