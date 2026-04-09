import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1).execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
  });

  group('SetInitCommand', () {
    test('should set initiative for a character', () {
      final command = SetInitCommand(character.id, 15);
      command.execute();
      expect(character.characterState.initiative.value, 15);
      checkSaveState();
    });

    test('should update initiative to a new value', () {
      SetInitCommand(character.id, 10).execute();
      SetInitCommand(character.id, 25).execute();
      expect(character.characterState.initiative.value, 25);
    });

    test('describe should include character id', () {
      final command = SetInitCommand('Blinkblade', 15);
      expect(command.describe(), 'Set initiative of Blinkblade');
    });
  });
}
