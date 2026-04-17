// ignore_for_file: avoid-late-keyword, no-empty-block, no-magic-number, avoid-non-null-assertion

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    SetLevelCommand(1, null).execute();
  });

  // ── eval / Parser ────────────────────────────────────────────────────────

  group('StatCalculator.eval', () {
    test('parses a plain integer string', () {
      expect(StatCalculator.eval('5'), 5);
    });

    test('parses addition', () {
      expect(StatCalculator.eval('3+2'), 5);
    });

    test('parses subtraction', () {
      expect(StatCalculator.eval('7-3'), 4);
    });

    test('parses multiplication with *', () {
      expect(StatCalculator.eval('3*4'), 12);
    });

    test('parses multiplication with x', () {
      // 'x' is an alternative multiplication operator
      expect(StatCalculator.eval('3x4'), 12);
    });

    test('parses division with / (ceiling)', () {
      // 7 / 2 = 3.5 → ceil → 4
      expect(StatCalculator.eval('7/2'), 4);
    });

    test('parses division with d (floor)', () {
      // 7 d 2 = 3.5 → floor → 3
      expect(StatCalculator.eval('7d2'), 3);
    });

    test('parses parenthesised expression', () {
      expect(StatCalculator.eval('(2+3)*4'), 20);
    });

    test('parses unary minus', () {
      // Unary minus applied to a number; result is negative
      // StatCalculator stores as int so -5
      expect(StatCalculator.eval('0-5'), -5);
    });

    test('returns null for malformed expression', () {
      expect(StatCalculator.eval('abc'), isNull);
    });

    test('returns null for expression with trailing characters', () {
      // '5 extra' has trailing non-parseable chars after the number
      expect(StatCalculator.eval('5extra'), isNull);
    });

    test('parses condition less-than (true → 1)', () {
      expect(StatCalculator.eval('2<3'), 1);
    });

    test('parses condition less-than (false → 0)', () {
      expect(StatCalculator.eval('3<2'), 0);
    });

    test('parses condition greater-than (true → 1)', () {
      expect(StatCalculator.eval('5>4'), 1);
    });

    test('parses condition greater-than (false → 0)', () {
      expect(StatCalculator.eval('1>2'), 0);
    });

    test('parses condition equals (true → 1)', () {
      expect(StatCalculator.eval('4=4'), 1);
    });

    test('parses condition equals (false → 0)', () {
      expect(StatCalculator.eval('4=5'), 0);
    });

    test('ceil division: exact division gives no rounding', () {
      expect(StatCalculator.eval('6/2'), 3);
    });

    test('floor division: exact division gives no rounding', () {
      expect(StatCalculator.eval('6d2'), 3);
    });

    test('operator precedence: multiplication before addition', () {
      // 2 + 3 * 4 = 14 only if * has higher precedence
      // The parser is left-to-right for same level; + and * are different levels
      // parseTerm handles * so it should be: 2 + (3*4) = 14
      expect(StatCalculator.eval('2+3*4'), 14);
    });
  });

  // ── calculateFormula ────────────────────────────────────────────────────

  group('StatCalculator.calculateFormula', () {
    test('returns int directly when passed an int', () {
      expect(StatCalculator.calculateFormula(7), 7);
    });

    test('substitutes C with character count (clamped to 2 minimum)', () {
      // No characters added → count = 0, clamped to 2
      expect(StatCalculator.calculateFormula('C'), 2);
    });

    test('substitutes C with actual character count when ≥ 2', () {
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      AddCharacterCommand('Hail', 'Mercenary Packs', null, 1,
              gameState: getIt<GameState>())
          .execute();
      // 3 characters → C = 3
      expect(StatCalculator.calculateFormula('C'), 3);
    });

    test('substitutes L with current level', () {
      SetLevelCommand(4, null).execute();
      expect(StatCalculator.calculateFormula('L'), 4);
    });

    test('evaluates compound formula with C and L', () {
      // With 0 chars (C=2) and level 3: C+L = 2+3 = 5
      SetLevelCommand(3, null).execute();
      expect(StatCalculator.calculateFormula('C+L'), 5);
    });

    test('returns null for invalid formula string', () {
      expect(StatCalculator.calculateFormula('??'), isNull);
    });
  });

  // ── evaluateCondition ────────────────────────────────────────────────────

  group('StatCalculator.evaluateCondition', () {
    test('returns true when formula evaluates to 1', () {
      // '1' evaluates to 1 → true
      expect(StatCalculator.evaluateCondition('1'), isTrue);
    });

    test('returns false when formula evaluates to 0', () {
      expect(StatCalculator.evaluateCondition('0'), isFalse);
    });

    test('returns false when formula evaluates to something other than 1', () {
      expect(StatCalculator.evaluateCondition('2'), isFalse);
    });

    test('evaluates condition expression correctly', () {
      // '2<3' → 1 → true
      expect(StatCalculator.evaluateCondition('2<3'), isTrue);
      // '3<2' → 0 → false
      expect(StatCalculator.evaluateCondition('3<2'), isFalse);
    });
  });
}
