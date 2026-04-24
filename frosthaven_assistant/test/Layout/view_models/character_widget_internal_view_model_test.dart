// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/character_widget_internal_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;

  setUp(() {
    getIt<GameState>().clearList();
    (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
        RoundState.chooseInitiative;
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>()
        .currentList
        .firstWhere((e) => e is Character) as Character;
    (character.characterState.initiative as ValueNotifier<int>).value = 0;
  });

  CharacterWidgetInternalViewModel makeVm() =>
      CharacterWidgetInternalViewModel(
        character,
        gameState: getIt<GameState>(),
        settings: getIt<Settings>(),
      );

  group('CharacterWidgetInternalViewModel.isObjectiveOrEscort', () {
    test('returns false for a regular character', () {
      expect(makeVm().isObjectiveOrEscort, isFalse);
    });
  });

  group('CharacterWidgetInternalViewModel.roundState', () {
    test('reflects chooseInitiative state', () {
      expect(makeVm().roundState, RoundState.chooseInitiative);
    });

    test('reflects playTurns state', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      expect(makeVm().roundState, RoundState.playTurns);
    });
  });

  group('CharacterWidgetInternalViewModel.isChooseInitiative', () {
    test('true when roundState is chooseInitiative', () {
      expect(makeVm().isChooseInitiative, isTrue);
    });

    test('false when roundState is playTurns', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      expect(makeVm().isChooseInitiative, isFalse);
    });
  });

  group('CharacterWidgetInternalViewModel.isAlive', () {
    test('true when character health > 0', () {
      expect(character.characterState.health.value, greaterThan(0));
      expect(makeVm().isAlive, isTrue);
    });

    test('false when character health is 0', () {
      (character.characterState.health as ValueNotifier<int>).value = 0;
      expect(makeVm().isAlive, isFalse);
    });
  });

  group('CharacterWidgetInternalViewModel.handleInitTextChange', () {
    test('returns false for empty text', () {
      expect(makeVm().handleInitTextChange(''), isFalse);
    });

    test('returns false for "??" text', () {
      expect(makeVm().handleInitTextChange('??'), isFalse);
    });

    test('returns false for non-numeric text', () {
      expect(makeVm().handleInitTextChange('abc'), isFalse);
    });

    test('returns false for zero', () {
      expect(makeVm().handleInitTextChange('0'), isFalse);
    });

    test('returns false when text equals current initiative', () {
      (character.characterState.initiative as ValueNotifier<int>).value = 42;
      expect(makeVm().handleInitTextChange('42'), isFalse);
    });

    test('returns true and dispatches SetInitCommand for valid new initiative',
        () {
      final gs = getIt<GameState>();
      final indexBefore = gs.commandIndex.value;
      final result = makeVm().handleInitTextChange('55');
      expect(result, isTrue);
      expect(gs.commandIndex.value, greaterThan(indexBefore));
      expect(character.characterState.initiative.value, 55);
      gs.undo();
    });

    test('handles valid single-digit initiative', () {
      final result = makeVm().handleInitTextChange('5');
      expect(result, isTrue);
      getIt<GameState>().undo();
    });

    test('returns false when character not in current list', () {
      // Remove character from list and try again
      getIt<GameState>().clearList();
      expect(makeVm().handleInitTextChange('50'), isFalse);
    });
  });

  group('CharacterWidgetInternalViewModel.endTurn', () {
    test('dispatches TurnDoneCommand and changes turnState', () {
      final gs = getIt<GameState>();
      (gs.roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      (character.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.current;
      makeVm().endTurn();
      expect(character.turnState.value, TurnsState.done);
      gs.undo();
    });
  });
}
