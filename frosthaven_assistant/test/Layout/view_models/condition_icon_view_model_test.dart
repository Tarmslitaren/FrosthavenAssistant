// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/condition_icon_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
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

  ConditionIconViewModel makeVm() => ConditionIconViewModel(
        gameState: getIt<GameState>(),
        settings: getIt<Settings>(),
        communication: getIt<Communication>(),
      );

  // ── isCharacterCondition ───────────────────────────────────────────────────

  group('ConditionIconViewModel.isCharacterCondition', () {
    test('matches whether condition name contains "character"', () {
      final vm = makeVm();
      for (final c in Condition.values) {
        final expected = c.name.contains('character');
        expect(vm.isCharacterCondition(c), expected,
            reason:
                'Condition.${c.name} → isCharacterCondition should be $expected');
      }
    });

    test('false for standard game conditions', () {
      final vm = makeVm();
      final standard = [
        Condition.poison,
        Condition.wound,
        Condition.stun,
        Condition.muddle,
        Condition.immobilize,
        Condition.disarm,
        Condition.strengthen,
        Condition.invisible,
        Condition.regenerate,
        Condition.brittle,
        Condition.bane,
        Condition.rupture,
        Condition.ward,
        Condition.infect,
      ];
      for (final c in standard) {
        expect(vm.isCharacterCondition(c), isFalse,
            reason: 'Condition.${c.name} should not be a character condition');
      }
    });

    test('true for character1..character4', () {
      final vm = makeVm();
      expect(vm.isCharacterCondition(Condition.character1), isTrue);
      expect(vm.isCharacterCondition(Condition.character2), isTrue);
      expect(vm.isCharacterCondition(Condition.character3), isTrue);
      expect(vm.isCharacterCondition(Condition.character4), isTrue);
    });
  });

  // ── classColorFor ──────────────────────────────────────────────────────────

  group('ConditionIconViewModel.classColorFor', () {
    test('returns transparent for all non-character conditions', () {
      final vm = makeVm();
      final standard = [
        Condition.poison,
        Condition.wound,
        Condition.stun,
        Condition.muddle,
        Condition.regenerate,
        Condition.brittle,
      ];
      for (final c in standard) {
        expect(vm.classColorFor(c), Colors.transparent,
            reason: 'Expected transparent for Condition.${c.name}');
      }
    });

    test('returns transparent for character condition when no character loaded',
        () {
      // No characters in list → no match → transparent.
      expect(makeVm().classColorFor(Condition.character1), Colors.transparent);
    });
  });

  // ── commandIndex ───────────────────────────────────────────────────────────

  group('ConditionIconViewModel.commandIndex', () {
    test('listenable is exposed and of type ValueListenable<int>', () {
      final vl = makeVm().commandIndex;
      expect(vl, isA<ValueListenable<int>>());
    });
  });

  // ── getOldState ────────────────────────────────────────────────────────────

  group('ConditionIconViewModel.getOldState', () {
    test('returns null immediately after clearList (no save history)', () {
      // clearList does not create a save state, so getOldState should be null.
      final result = makeVm().getOldState();
      expect(result, isNull);
    });

    test('returns a non-null GameState after action() builds save history', () {
      final gs = getIt<GameState>();
      // action() goes through the ActionHandler, which saves state before
      // executing the command.
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final result = makeVm().getOldState();
      expect(result, isNotNull);
      gs.undo();
    });
  });

  // ── getTurnChanged ─────────────────────────────────────────────────────────

  group('ConditionIconViewModel.getTurnChanged', () {
    test('returns null when round values differ between states', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final savedRound = gs.round.value;
      (gs.round as ValueNotifier<int>).value = savedRound + 1;
      expect(vm.getTurnChanged(old, gs), isNull);
      (gs.round as ValueNotifier<int>).value = savedRound;
      gs.undo();
    });

    test('returns null when roundState values differ', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      (gs.roundState as ValueNotifier<RoundState>).value = RoundState.playTurns;
      expect(vm.getTurnChanged(old, gs), isNull);
      (gs.roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
      gs.undo();
    });

    test('returns null when list lengths differ', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      // Add another item after capturing the old state.
      gs.action(AddMonsterCommand('Ancient Artillery (FH)', 1, false,
          gameState: gs));
      expect(vm.getTurnChanged(old, gs), isNull);
      gs.undo();
      gs.undo();
    });

    test('returns index when a turnState changed for the same ids', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final item = gs.currentList.first;
      (item.turnState as ValueNotifier<TurnsState>).value = TurnsState.done;
      final changed = vm.getTurnChanged(old, gs);
      expect(changed, 0);
      (item.turnState as ValueNotifier<TurnsState>).value = TurnsState.notDone;
      gs.undo();
    });

    test('returns null when no items changed turnState', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      // No change – turnState is still notDone in both old and current.
      expect(vm.getTurnChanged(old, gs), isNull);
      gs.undo();
    });
  });

  // ── shouldTriggerAnimation – health-change branches ───────────────────────

  group('ConditionIconViewModel.shouldTriggerAnimation (health change)', () {
    test('returns true for poison condition when owner takes damage', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      final oldHealth = character.characterState.health.value;
      // Simulate taking damage (negative health change from old to current).
      (character.characterState.health as ValueNotifier<int>).value =
          oldHealth - 3;

      final result = vm.shouldTriggerAnimation(
        condition: Condition.poison,
        owner: character,
        figure: character.characterState,
        oldState: old,
      );
      expect(result, isTrue);
      (character.characterState.health as ValueNotifier<int>).value = oldHealth;
      gs.undo();
    });

    test('returns true for wound when owner receives healing', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      final oldHealth = character.characterState.health.value;
      // Simulate healing (positive health change).
      (character.characterState.health as ValueNotifier<int>).value =
          oldHealth + 3;

      final result = vm.shouldTriggerAnimation(
        condition: Condition.wound,
        owner: character,
        figure: character.characterState,
        oldState: old,
      );
      expect(result, isTrue);
      (character.characterState.health as ValueNotifier<int>).value = oldHealth;
      gs.undo();
    });

    test('returns false for stun condition when owner takes damage', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      final oldHealth = character.characterState.health.value;
      (character.characterState.health as ValueNotifier<int>).value =
          oldHealth - 3;

      final result = vm.shouldTriggerAnimation(
        condition: Condition.stun,
        owner: character,
        figure: character.characterState,
        oldState: old,
      );
      expect(result, isFalse);
      (character.characterState.health as ValueNotifier<int>).value = oldHealth;
      gs.undo();
    });

    test('returns false when a different owner takes damage', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      gs.action(AddMonsterCommand('Ancient Artillery (FH)', 1, false,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final monster = gs.currentList.firstWhere((e) => e is Monster) as Monster;
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;

      if (monster.monsterInstances.isNotEmpty) {
        final standee = monster.monsterInstances.first;
        final oldHealth = standee.health.value;
        (standee.health as ValueNotifier<int>).value = oldHealth - 2;
        final result = vm.shouldTriggerAnimation(
          condition: Condition.poison,
          owner: character,
          figure: character.characterState,
          oldState: old,
        );
        expect(result, isFalse);
        (standee.health as ValueNotifier<int>).value = oldHealth;
      }
      gs.undo();
      gs.undo();
    });

    test('returns false for ward (defensive) when owner receives healing', () {
      final gs = getIt<GameState>();
      gs.action(AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
          gameState: gs));
      final vm = makeVm();
      final old = vm.getOldState()!;
      final character =
          gs.currentList.firstWhere((e) => e is Character) as Character;
      final oldHealth = character.characterState.health.value;
      (character.characterState.health as ValueNotifier<int>).value =
          oldHealth + 3;

      final result = vm.shouldTriggerAnimation(
        condition: Condition.ward,
        owner: character,
        figure: character.characterState,
        oldState: old,
      );
      // ward is not in the healing-triggered list
      expect(result, isFalse);
      (character.characterState.health as ValueNotifier<int>).value = oldHealth;
      gs.undo();
    });
  });
}
