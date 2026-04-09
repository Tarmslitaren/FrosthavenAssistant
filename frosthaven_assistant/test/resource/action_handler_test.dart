import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
  });

  group('ActionHandler', () {
    group('getCurrent', () {
      test('getCurrent returns the last executed command', () {
        final gs = getIt<GameState>();
        final cmd = SetLevelCommand(3, null);
        gs.action(cmd);
        expect(gs.getCurrent(), same(cmd));
        gs.undo();
      });
    });

    group('redo', () {
      test('redo restores state after undo', () {
        final gs = getIt<GameState>();
        // Two actions so gameSaveStates has enough entries for redo
        gs.action(SetLevelCommand(2, null));
        gs.action(SetLevelCommand(5, null));
        expect(gs.level.value, 5);
        gs.undo(); // back to level 2
        expect(gs.level.value, 2);
        gs.redo(); // forward to level 5
        expect(gs.level.value, 5);
        gs.undo();
        gs.undo();
      });

      test('redo is a no-op when there is nothing to redo', () {
        final gs = getIt<GameState>();
        gs.action(SetLevelCommand(4, null));
        // No undo performed, so redo should not crash and not change state
        final levelBefore = gs.level.value;
        gs.redo();
        expect(gs.level.value, levelBefore);
        gs.undo();
      });

      test('redo increments commandIndex', () {
        final gs = getIt<GameState>();
        gs.action(SetLevelCommand(2, null));
        gs.action(SetLevelCommand(3, null));
        final indexAfterActions = gs.commandIndex.value;
        gs.undo();
        expect(gs.commandIndex.value, indexAfterActions - 1);
        gs.redo();
        expect(gs.commandIndex.value, indexAfterActions);
        gs.undo();
        gs.undo();
      });
    });

    group('redo list cleanup', () {
      test('new action after undo clears the redo list', () {
        final gs = getIt<GameState>();
        gs.action(SetLevelCommand(3, null));
        gs.action(SetLevelCommand(4, null));
        final indexBefore = gs.commandIndex.value;
        gs.undo(); // undo SetLevel(4), now commandIndex = indexBefore - 1
        // Do a new action — should clear SetLevel(4) from the redo list
        gs.action(SetLevelCommand(5, null));
        // commands length should equal commandIndex + 1 (no redo entries)
        expect(gs.commands.length - 1, gs.commandIndex.value);
        expect(gs.commandDescriptions.length - 1, gs.commandIndex.value);
        // Undo back to baseline
        gs.undo();
        gs.undo();
      });
    });

    group('maxUndo eviction', () {
      test('commands and gameSaveStates beyond maxUndo are nulled', () {
        final gs = getIt<GameState>();
        final maxUndo = gs.maxUndo;
        final startIndex = gs.commandIndex.value;

        // Execute maxUndo + 1 commands to trigger eviction
        for (int i = 0; i <= maxUndo; i++) {
          gs.action(SetLevelCommand((i % 7) + 1, null));
        }
        // After maxUndo+1 actions, the oldest command entry should be nulled
        expect(gs.commands[startIndex + 1], isNull);
        // gameSaveStates at oldest entry should also be nulled
        expect(gs.gameSaveStates[startIndex + 1], isNull);

        // Undo back to near the start (only valid undo states)
        for (int i = 0; i < maxUndo; i++) {
          gs.undo();
        }
      });
    });

    group('add monster then undo', () {
      test('undo after adding a monster removes it from the list', () {
        final gs = getIt<GameState>();
        gs.clearList();
        gs.action(AddMonsterCommand('Zealot', 1, false));
        expect(gs.currentList.any((e) => e.id == 'Zealot'), isTrue);
        gs.undo();
        expect(gs.currentList.any((e) => e.id == 'Zealot'), isFalse);
      });
    });
  });
}
