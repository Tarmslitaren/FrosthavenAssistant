// ignore_for_file: no-magic-number, avoid-non-null-assertion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/condition_icon_view_model.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../unit_helpers.dart';

void main() {
  late Settings settings;
  late GameState gameState;

  setUpAll(initTestBinding);

  setUp(() {
    (gameState, settings) = makeGameAndSettings();
    settings.expireConditions.value = true;
  });

  ConditionIconViewModel makeVm() => ConditionIconViewModel(
        settings: settings,
        gameState: gameState,
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
      expect(makeVm().classColorFor(Condition.character1), Colors.transparent);
    });
  });

  // ── shouldAnimateOnDamage ──────────────────────────────────────────────────

  group('ConditionIconViewModel.shouldAnimateOnDamage', () {
    test('true for damage-sensitive conditions', () {
      final vm = makeVm();
      for (final c in [
        Condition.poison,
        Condition.regenerate,
        Condition.ward,
        Condition.shield,
        Condition.retaliate,
        Condition.brittle,
      ]) {
        expect(vm.shouldAnimateOnDamage(c), isTrue,
            reason: '${c.name} should animate on damage');
      }
    });

    test('true for poison2 (name contains "poison")', () {
      expect(makeVm().shouldAnimateOnDamage(Condition.poison2), isTrue);
    });

    test('false for conditions not triggered by damage', () {
      final vm = makeVm();
      for (final c in [
        Condition.stun,
        Condition.disarm,
        Condition.wound,
        Condition.rupture,
        Condition.infect,
        Condition.bane,
        Condition.muddle,
      ]) {
        expect(vm.shouldAnimateOnDamage(c), isFalse,
            reason: '${c.name} should NOT animate on damage');
      }
    });
  });

  // ── shouldAnimateOnHeal ────────────────────────────────────────────────────

  group('ConditionIconViewModel.shouldAnimateOnHeal', () {
    test('true for heal-sensitive conditions', () {
      final vm = makeVm();
      for (final c in [
        Condition.rupture,
        Condition.wound,
        Condition.bane,
        Condition.infect,
        Condition.brittle,
      ]) {
        expect(vm.shouldAnimateOnHeal(c), isTrue,
            reason: '${c.name} should animate on heal');
      }
    });

    test('true for poison (name contains "poison") on heal', () {
      expect(makeVm().shouldAnimateOnHeal(Condition.poison), isTrue);
    });

    test('false for conditions not triggered by healing', () {
      final vm = makeVm();
      for (final c in [
        Condition.stun,
        Condition.disarm,
        Condition.ward,
        Condition.shield,
        Condition.regenerate,
        Condition.retaliate,
        Condition.muddle,
      ]) {
        expect(vm.shouldAnimateOnHeal(c), isFalse,
            reason: '${c.name} should NOT animate on heal');
      }
    });
  });

  // ── shouldAnimateOnTurnStart ───────────────────────────────────────────────

  group('ConditionIconViewModel.shouldAnimateOnTurnStart', () {
    test('true for regenerate, wound, wound2', () {
      final vm = makeVm();
      expect(vm.shouldAnimateOnTurnStart(Condition.regenerate), isTrue);
      expect(vm.shouldAnimateOnTurnStart(Condition.wound), isTrue);
      expect(vm.shouldAnimateOnTurnStart(Condition.wound2), isTrue);
    });

    test('false for conditions not triggered at turn start', () {
      final vm = makeVm();
      for (final c in [
        Condition.poison,
        Condition.stun,
        Condition.muddle,
        Condition.bane,
        Condition.rupture,
        Condition.brittle,
      ]) {
        expect(vm.shouldAnimateOnTurnStart(c), isFalse,
            reason: '${c.name} should NOT animate on turn start');
      }
    });
  });

  // ── shouldAnimateOnTurnEnd ─────────────────────────────────────────────────

  group('ConditionIconViewModel.shouldAnimateOnTurnEnd', () {
    test('true for bane when NOT added this turn', () {
      expect(makeVm().shouldAnimateOnTurnEnd(Condition.bane, [], []), isTrue);
    });

    test('false for bane when added this turn', () {
      expect(makeVm().shouldAnimateOnTurnEnd(
          Condition.bane, [Condition.bane], []), isFalse);
    });

    test('true for stun added previous turn when expireConditions=false', () {
      settings.expireConditions.value = false;
      expect(makeVm().shouldAnimateOnTurnEnd(
          Condition.stun, [], [Condition.stun]), isTrue);
    });

    test('false for stun added previous turn when expireConditions=true', () {
      settings.expireConditions.value = true;
      expect(makeVm().shouldAnimateOnTurnEnd(
          Condition.stun, [], [Condition.stun]), isFalse);
    });

    test('false for wound at turn end (wound is turn-start, not turn-end)', () {
      expect(makeVm().shouldAnimateOnTurnEnd(Condition.wound, [], []), isFalse);
    });
  });
}
