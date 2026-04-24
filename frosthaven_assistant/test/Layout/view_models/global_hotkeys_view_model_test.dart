// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/global_hotkeys_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
        RoundState.chooseInitiative;
  });

  GlobalHotkeysViewModel makeVm() =>
      GlobalHotkeysViewModel(gameState: getIt<GameState>());

  group('GlobalHotkeysViewModel.toggleElement', () {
    test('imbues inert fire element to full', () {
      final gs = getIt<GameState>();
      expect(gs.elementState[Elements.fire], ElementState.inert);
      makeVm().toggleElement(Elements.fire);
      expect(gs.elementState[Elements.fire], ElementState.full);
      gs.undo();
    });

    test('uses element when full', () {
      final gs = getIt<GameState>();
      makeVm().toggleElement(Elements.ice); // inert → full
      expect(gs.elementState[Elements.ice], ElementState.full);
      makeVm().toggleElement(Elements.ice); // full → inert
      expect(gs.elementState[Elements.ice], ElementState.inert);
      gs.undo();
      gs.undo();
    });

    test('uses element when half', () {
      final gs = getIt<GameState>();
      gs.action(ImbueElementCommand(Elements.earth, true)); // inert → half
      expect(gs.elementState[Elements.earth], ElementState.half);
      makeVm().toggleElement(Elements.earth); // half → inert
      expect(gs.elementState[Elements.earth], ElementState.inert);
      gs.undo();
      gs.undo();
    });
  });

  group('GlobalHotkeysViewModel.invokeDrawOrNextRound', () {
    test('returns blocked message when no characters', () {
      final msg = makeVm().invokeDrawOrNextRound();
      expect(msg, isNotNull);
    });

    test('returns null when character with initiative succeeds draw', () {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: gs)
          .execute();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      (character.characterState.initiative as ValueNotifier<int>).value = 50;
      final msg = makeVm().invokeDrawOrNextRound();
      expect(msg, isNull);
      gs.undo(); // undo draw
      gs.undo(); // undo add character
    });
  });

  group('GlobalHotkeysViewModel.advanceActivation', () {
    test('does nothing when not in playTurns', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
      final indexBefore = getIt<GameState>().commandIndex.value;
      makeVm().advanceActivation();
      expect(getIt<GameState>().commandIndex.value, indexBefore);
    });

    test('marks current item as done in playTurns', () {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: gs)
          .execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false, gameState: gs)
          .execute();
      DrawCommand(gameState: gs).execute();
      expect(gs.currentList.first.turnState.value, TurnsState.current);

      makeVm().advanceActivation();

      expect(gs.currentList.first.turnState.value, TurnsState.done);
      gs.undo();
      gs.undo();
      gs.undo();
      gs.undo();
    });
  });

  group('GlobalHotkeysViewModel.undoActivation', () {
    test('does nothing when last command is not TurnDoneCommand', () {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: gs)
          .execute();
      final indexBefore = gs.commandIndex.value;
      makeVm().undoActivation();
      expect(gs.commandIndex.value, indexBefore);
      gs.undo();
    });

    test('undoes when last command is TurnDoneCommand', () {
      final gs = getIt<GameState>();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1, gameState: gs)
          .execute();
      AddMonsterCommand('Ancient Artillery (FH)', 1, false, gameState: gs)
          .execute();
      DrawCommand(gameState: gs).execute();
      gs.action(TurnDoneCommand(gs.currentList.first.id, gameState: gs));
      final indexAfterTurnDone = gs.commandIndex.value;

      makeVm().undoActivation();

      expect(gs.commandIndex.value, indexAfterTurnDone - 1);
      gs.undo();
      gs.undo();
      gs.undo();
    });
  });

  group('GlobalHotkeysViewModel.undo/redo', () {
    test('undo decrements commandIndex', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final indexAfterAdd = gs.commandIndex.value;
      makeVm().undo();
      expect(gs.commandIndex.value, indexAfterAdd - 1);
    });

    test('redo re-applies undone command', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final indexAfterAdd = gs.commandIndex.value;
      makeVm().undo();
      makeVm().redo();
      expect(gs.commandIndex.value, indexAfterAdd);
      gs.undo();
    });
  });
}
