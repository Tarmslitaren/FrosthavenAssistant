// ignore_for_file: no-magic-number, avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_character_level_command.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('SetCharacterLevelCommand', () {
    test('should set character level', () {
      final command = SetCharacterLevelCommand(3, character.id);
      command.execute();
      expect(character.characterState.level.value, 3);
      checkSaveState();
    });

    test('should update max health when level changes', () {
      final healthAtLevel1 = character.characterState.maxHealth.value;
      SetCharacterLevelCommand(5, character.id).execute();
      expect(character.characterState.maxHealth.value,
          greaterThanOrEqualTo(healthAtLevel1));
    });

    test('describe should include character id', () {
      final command = SetCharacterLevelCommand(3, 'Blinkblade');
      expect(command.describe(), "Set Blinkblade's Level");
    });
  });
}
