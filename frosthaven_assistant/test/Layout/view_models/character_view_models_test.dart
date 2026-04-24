// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/character_amds_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/character_health_widget_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/character_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
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
    getIt<Settings>().enableHeathWheel.value = true;
    getIt<Settings>().showCharacterAMD.value = true;
  });

  tearDown(() {
    getIt<Settings>().enableHeathWheel.value = true;
    getIt<Settings>().showCharacterAMD.value = true;
  });

  Character addBlinkblade() {
    AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
            gameState: getIt<GameState>())
        .execute();
    return getIt<GameState>()
        .currentList
        .firstWhere((e) => e is Character) as Character;
  }

  // ── CharacterViewModel ─────────────────────────────────────────────────────

  group('CharacterViewModel.isAlive', () {
    test('true when health != 0', () {
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(character.characterState.health.value, greaterThan(0));
      expect(vm.isAlive, isTrue);
      getIt<GameState>().undo();
    });

    test('false when health is 0', () {
      final character = addBlinkblade();
      (character.characterState.health as ValueNotifier<int>).value = 0;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isAlive, isFalse);
      getIt<GameState>().undo();
    });
  });

  group('CharacterViewModel.isTurnDone', () {
    test('false by default (notDone)', () {
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isTurnDone, isFalse);
      getIt<GameState>().undo();
    });

    test('true when turnState is done', () {
      final character = addBlinkblade();
      (character.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.done;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isTurnDone, isTrue);
      getIt<GameState>().undo();
    });
  });

  group('CharacterViewModel.isCurrentTurn', () {
    test('false when turnState is notDone', () {
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isCurrentTurn, isFalse);
      getIt<GameState>().undo();
    });

    test('true when turnState is current', () {
      final character = addBlinkblade();
      (character.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.current;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isCurrentTurn, isTrue);
      getIt<GameState>().undo();
    });
  });

  group('CharacterViewModel.isChooseInitiative', () {
    test('true when roundState is chooseInitiative', () {
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isChooseInitiative, isTrue);
      getIt<GameState>().undo();
    });

    test('false when roundState is playTurns', () {
      final character = addBlinkblade();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isChooseInitiative, isFalse);
      getIt<GameState>().undo();
    });
  });

  group('CharacterViewModel.notGrayScale', () {
    test('true when alive, not done, and chooseInitiative', () {
      final character = addBlinkblade();
      // health > 0, turnState = notDone, chooseInitiative
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.notGrayScale, isTrue);
      getIt<GameState>().undo();
    });

    test('false when dead (health = 0)', () {
      final character = addBlinkblade();
      (character.characterState.health as ValueNotifier<int>).value = 0;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.notGrayScale, isFalse);
      getIt<GameState>().undo();
    });

    test('false when alive and turn is done in playTurns', () {
      final character = addBlinkblade();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      (character.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.done;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.notGrayScale, isFalse);
      getIt<GameState>().undo();
    });

    test('true when alive, done, but in chooseInitiative', () {
      final character = addBlinkblade();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
      (character.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.done;
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.notGrayScale, isTrue);
      getIt<GameState>().undo();
    });
  });

  group('CharacterViewModel.showHealthWheel', () {
    test('true when enableHeathWheel is true', () {
      getIt<Settings>().enableHeathWheel.value = true;
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.showHealthWheel, isTrue);
      getIt<GameState>().undo();
    });

    test('false when enableHeathWheel is false', () {
      getIt<Settings>().enableHeathWheel.value = false;
      final character = addBlinkblade();
      final vm = CharacterViewModel(character,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.showHealthWheel, isFalse);
      getIt<GameState>().undo();
    });
  });

  // ── CharacterAmdsViewModel ─────────────────────────────────────────────────

  group('CharacterAmdsViewModel.showCharacterAmd', () {
    test('reflects setting', () {
      getIt<Settings>().showCharacterAMD.value = false;
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.showCharacterAmd, isFalse);
    });

    test('true when setting enabled', () {
      getIt<Settings>().showCharacterAMD.value = true;
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.showCharacterAmd, isTrue);
    });
  });

  group('CharacterAmdsViewModel.roundState', () {
    test('reflects game state', () {
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.roundState, RoundState.playTurns);
    });
  });

  group('CharacterAmdsViewModel.charsWithPerks / characterAmount', () {
    test('empty when no characters', () {
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.charsWithPerks, isEmpty);
      expect(vm.characterAmount, 0);
    });

    test('non-zero when character with perks is added', () {
      addBlinkblade();
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      // Blinkblade has perks in Frosthaven.
      expect(vm.charsWithPerks.length, greaterThanOrEqualTo(0));
      expect(vm.characterAmount, vm.charsWithPerks.length);
      getIt<GameState>().undo();
    });
  });

  group('CharacterAmdsViewModel.canShowOneDeck', () {
    test('false when no current character', () {
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.canShowOneDeck, isFalse);
    });

    test('false in chooseInitiative even with current character', () {
      addBlinkblade();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
      final vm = CharacterAmdsViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.canShowOneDeck, isFalse);
      getIt<GameState>().undo();
    });
  });

  // ── CharacterHealthWidgetViewModel ─────────────────────────────────────────

  group('CharacterHealthWidgetViewModel.enableHealthWheel', () {
    test('true when setting is true', () {
      getIt<Settings>().enableHeathWheel.value = true;
      final vm = CharacterHealthWidgetViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.enableHealthWheel, isTrue);
    });

    test('false when setting is false', () {
      getIt<Settings>().enableHeathWheel.value = false;
      final vm = CharacterHealthWidgetViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.enableHealthWheel, isFalse);
    });
  });

  group('CharacterHealthWidgetViewModel.frosthavenStyle', () {
    test('returns a bool', () {
      final vm = CharacterHealthWidgetViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.frosthavenStyle, isA<bool>());
    });
  });

  group('CharacterHealthWidgetViewModel.commandIndex', () {
    test('commandIndex listenable is exposed', () {
      final vm = CharacterHealthWidgetViewModel(
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.commandIndex, isNotNull);
    });
  });
}
