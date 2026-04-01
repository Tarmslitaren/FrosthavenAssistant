import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinky', 1).execute();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
  });

  group('DrawCommand', () {
    test('should set round state to playTurns', () {
      DrawCommand().execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      checkSaveState();
    });

    test('should set first list item turn state to current', () {
      DrawCommand().execute();
      expect(getIt<GameState>().currentList.first.turnState.value,
          TurnsState.current);
    });

    test('describe returns "Draw"', () {
      expect(DrawCommand().describe(), 'Draw');
    });
  });
}
