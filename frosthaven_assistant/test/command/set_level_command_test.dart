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

  group('SetLevelCommand', () {
    test('should set global level when monsterId is null', () {
      final command = SetLevelCommand(3, null);
      command.execute();
      expect(getIt<GameState>().level.value, 3);
      checkSaveState();
    });

    test('should set a specific monster level when monsterId is provided', () {
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      final monster = getIt<GameState>().currentList.firstWhere(
              (e) => e is Monster) as Monster;

      SetLevelCommand(4, monster.id).execute();

      expect(monster.level.value, 4);
      checkSaveState();
    });

    test('describe without monsterId returns "Set Level"', () {
      final command = SetLevelCommand(2, null);
      expect(command.describe(), 'Set Level');
    });

    test('describe with monsterId includes monster name', () {
      final command =
          SetLevelCommand(2, 'Ancient Artillery (FH)');
      expect(command.describe(), "Set Ancient Artillery (FH)'s level");
    });
  });
}
