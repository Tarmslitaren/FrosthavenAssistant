// ignore_for_file: avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
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

  group('TurnDoneCommand', () {
    test('should set character turn to current when not current', () {
      expect(character.turnState.value, isNot(TurnsState.current));

      TurnDoneCommand(character.id, gameState: getIt<GameState>()).execute();

      expect(character.turnState.value, TurnsState.current);
    });

    test('should mark character turn as done when current', () {
      // First call sets to current
      TurnDoneCommand(character.id, gameState: getIt<GameState>()).execute();
      expect(character.turnState.value, TurnsState.current);

      // Second call sets to done
      TurnDoneCommand(character.id, gameState: getIt<GameState>()).execute();

      expect(character.turnState.value, TurnsState.done);
      checkSaveState();
    });

    test('describe includes character id', () {
      final command =
          TurnDoneCommand(character.id, gameState: getIt<GameState>());
      expect(command.describe(), "${character.id}'s turn done");
    });
  });
}
