// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/draw_button_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
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
    (getIt<GameState>().round as ValueNotifier<int>).value = 1;
    (getIt<GameState>().totalRounds as ValueNotifier<int>).value = 1;
  });

  DrawButtonViewModel makeVm() => DrawButtonViewModel(
        gameState: getIt<GameState>(),
        settings: getIt(),
      );

  group('DrawButtonViewModel.buttonText', () {
    test('returns "Draw" in chooseInitiative state', () {
      expect(makeVm().buttonText, 'Draw');
    });

    test('returns " Next Round" in playTurns state', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      expect(makeVm().buttonText, ' Next Round');
    });
  });

  group('DrawButtonViewModel.roundText', () {
    test('returns round number alone when round equals totalRounds', () {
      (getIt<GameState>().round as ValueNotifier<int>).value = 3;
      (getIt<GameState>().totalRounds as ValueNotifier<int>).value = 3;
      expect(makeVm().roundText, '3');
    });

    test('returns "round(total)" format when round differs from totalRounds',
        () {
      (getIt<GameState>().round as ValueNotifier<int>).value = 2;
      (getIt<GameState>().totalRounds as ValueNotifier<int>).value = 5;
      expect(makeVm().roundText, '2(5)');
    });
  });

  group('DrawButtonViewModel.buttonWidth', () {
    test('returns narrow width when round equals totalRounds', () {
      (getIt<GameState>().round as ValueNotifier<int>).value = 1;
      (getIt<GameState>().totalRounds as ValueNotifier<int>).value = 1;
      expect(makeVm().buttonWidth, 60.0);
    });

    test('returns wider width when totalRounds differs from round', () {
      (getIt<GameState>().round as ValueNotifier<int>).value = 1;
      (getIt<GameState>().totalRounds as ValueNotifier<int>).value = 3;
      expect(makeVm().buttonWidth, 75.0);
    });
  });

  group('DrawButtonViewModel.runAction', () {
    test('returns blocked message when no characters have set initiative', () {
      final result = makeVm().runAction();
      expect(result, isNotNull);
    });

    test('returns null (success) when character has initiative set', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      (character.characterState.initiative as ValueNotifier<int>).value = 50;
      final result = makeVm().runAction();
      expect(result, isNull);
      gs.undo();
    });
  });

  group('DrawButtonViewModel notifiers', () {
    test('userScalingBars listenable is exposed', () {
      expect(makeVm().userScalingBars, isNotNull);
    });

    test('round listenable is exposed', () {
      expect(makeVm().round, isNotNull);
    });

    test('commandIndex listenable is exposed', () {
      expect(makeVm().commandIndex, isNotNull);
    });
  });
}
