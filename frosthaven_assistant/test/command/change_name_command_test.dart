// ignore_for_file: avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_name_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    AddCharacterCommand('Blinkblade', 'Frosthaven', "Blinky", 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('ChangeNameCommand', () {
    test('should change a character\'s name', () {
      // Arrange
      final newName = 'BlinkyTheBlade';
      final command = ChangeNameCommand(newName, character.id,
          gameState: getIt<GameState>());
      final initialName = character.characterState.display.value;
      expect(initialName, 'Blinky');

      // Act
      command.execute();

      // Assert
      final finalName = character.characterState.display.value;
      expect(finalName, newName);
      checkSaveState();
    });

    test('describe should return correct string', () {
      // Arrange
      final command = ChangeNameCommand('NewName', 'Blinkblade',
          gameState: getIt<GameState>());

      // Act & Assert
      expect(command.describe(), 'change character name');
    });
  });
}
