import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/line_builder/frosthaven_converter.dart';

void main() {
  // ── convertLinesToFH – keyword replacements ───────────────────────────────

  group('FrosthavenConverter.convertLinesToFH – keyword replacements', () {
    test('"Affect" is replaced by "%target%"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['Affect 2'], false);
      expect(result, contains('%target% 2'));
    });

    test('"damage" is replaced by "%damage%"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['Deal damage here'], false);
      expect(result.first, contains('%damage%'));
    });

    test('"damaged" does not become "%%damage%%d"', () {
      // "damage" → "%damage%", then "%damage%d" → "damaged", net no change
      final result =
          FrosthavenConverter.convertLinesToFH(['damaged item'], false);
      expect(result.first, 'damaged item');
    });

    test('"Target" is replaced by "%target%"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['Target 2'], false);
      expect(result.first, '%target% 2');
    });

    test('"Affect" → "Target" → "%target%" pipeline', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['Affect all', 'Affect'], false);
      for (final line in result) {
        expect(line.contains('Affect'), isFalse,
            reason: '"Affect" should have been converted');
      }
      expect(result.first, contains('%target%'));
    });

    test('"% " (percent-space) is collapsed to "%"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['50% health'], false);
      expect(result.first, '50%health');
    });

    test('lines that have no special keywords are preserved', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['Move 3'], false);
      expect(result, contains('Move 3'));
    });
  });

  // ── convertLinesToFH – applyStats flag ───────────────────────────────────

  group('FrosthavenConverter.convertLinesToFH – applyStats flag', () {
    test('applyStats=false collapses " + " to "+"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['3 + 1'], false);
      expect(result.first, '3+1');
    });

    test('applyStats=false collapses " - " to "-"', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['3 - 1'], false);
      expect(result.first, '3-1');
    });

    test('applyStats=true preserves " + " spacing', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['3 + 1'], true);
      expect(result.first, '3 + 1');
    });

    test('applyStats=true preserves " - " spacing', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['3 - 1'], true);
      expect(result.first, '3 - 1');
    });
  });

  // ── convertLinesToFH – [newLine] ─────────────────────────────────────────

  group('FrosthavenConverter.convertLinesToFH – [newLine]', () {
    test('[newLine] is converted to an empty string', () {
      final result =
          FrosthavenConverter.convertLinesToFH(['text', '[newLine]'], false);
      expect(result, contains(''));
    });
  });

  // ── convertLinesToFH – * lines reset subline state ───────────────────────

  group('FrosthavenConverter.convertLinesToFH – * lines', () {
    test('* line is passed through', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['*Move 3', '^%poison%'], false);
      expect(result.any((l) => l.startsWith('*')), isTrue);
    });

    test('* line after a real subline adds [subLineEnd]', () {
      // Establish a subline then reset with a * line
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^%poison%', '*Attack'], false);
      expect(result, contains('[subLineEnd]'));
    });

    test('after a * line no trailing [subLineEnd] is added', () {
      // * line resets isReallySubLine, so no trailing marker
      final result =
          FrosthavenConverter.convertLinesToFH(['*Move 3'], false);
      expect(result.last, isNot('[subLineEnd]'));
    });
  });

  // ── convertLinesToFH – subline markers ───────────────────────────────────

  group('FrosthavenConverter.convertLinesToFH – subline markers', () {
    test('^%token% after a normal line inserts ![subLineStart]', () {
      // "Move 3" sets isSubLine=true; "^%poison%" triggers subLineStart
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^%poison%'], false);
      expect(result, contains('![subLineStart]'));
    });

    test('trailing [subLineEnd] is added when subline is open at end', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^%poison%'], false);
      expect(result.last, '[subLineEnd]');
    });

    test('^ line matching subline pattern gets "!" prefix', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^%poison%'], false);
      expect(result.any((l) => l.startsWith('!^')), isTrue);
    });

    test('^Target after a normal line triggers subline', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['Attack 3', '^%target% 2'], false);
      expect(result, contains('![subLineStart]'));
    });

    test('^Self after a normal line triggers subline', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['Heal 2', '^Self'], false);
      // "^Self" starts a subline and gets "!" prefix
      expect(result, contains('![subLineStart]'));
    });

    test('^ line that does NOT match subline pattern keeps isSubLine false', () {
      // "^Target all attacks" explicitly excluded from subline trigger
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^All attacks on you'], false);
      expect(result.contains('![subLineStart]'), isFalse);
    });

    test('second ^ line inside a subline is also prefixed with "!"', () {
      // Both ^ lines get the "!" prefix inside the subline block
      final result = FrosthavenConverter.convertLinesToFH(
          ['Move 3', '^%poison%', '^%wound%'], false);
      final exclamLines =
          result.where((l) => l.startsWith('!') && l.contains('%')).toList();
      expect(exclamLines.length, greaterThanOrEqualTo(2));
    });

    test('empty list returns empty list', () {
      final result = FrosthavenConverter.convertLinesToFH([], false);
      expect(result, isEmpty);
    });

    test('single non-special line has no subline markers', () {
      final result = FrosthavenConverter.convertLinesToFH(['Move 3'], false);
      expect(result.contains('[subLineStart]'), isFalse);
      expect(result.contains('![subLineStart]'), isFalse);
      expect(result.contains('[subLineEnd]'), isFalse);
    });
  });

  // ── convertLinesToFH – element use / conditional ─────────────────────────

  group('FrosthavenConverter.convertLinesToFH – element use block', () {
    test('[r] before a %use line marks the block as conditional', () {
      // The next line contains %use: isConditional=true, startOfConditional=true
      // The ^ subline immediately after should NOT get [subLineStart] due to startOfConditional
      final result = FrosthavenConverter.convertLinesToFH(
          ['Attack 2', '[r]', '%use%', '^%poison%', '[/r]'], false);
      // isConditional suppresses [subLineStart] on the first ^ line
      // verify no crash and the block is in the result
      expect(result, isNotEmpty);
    });

    test('[/r] resets the conditional flag', () {
      final result = FrosthavenConverter.convertLinesToFH(
          ['[r]', '%use%', '%fire%', '[/r]', 'Move 3', '^%poison%'], false);
      // After [/r] the block is normal; subsequent ^ should still add subLineStart
      expect(result, contains('![subLineStart]'));
    });
  });

  // ── shouldOverflow ────────────────────────────────────────────────────────

  group('FrosthavenConverter.shouldOverflow', () {
    const knownOverflowTokens = [
      'pierce', 'brittle', 'curse', 'enfeeble', 'bless',
      'invisible', 'strengthen', 'bane', 'push', 'pull',
      'poison', 'wound', 'infect', 'chill', 'disarm',
      'immobilize', 'stun', 'impair', 'safeguard', 'muddle',
    ];

    for (final token in knownOverflowTokens) {
      test('frosthavenStyle=true, token="$token" → true', () {
        expect(FrosthavenConverter.shouldOverflow(true, token, true), isTrue);
        expect(FrosthavenConverter.shouldOverflow(true, token, false), isTrue);
      });
    }

    test('frosthavenStyle=false always returns false', () {
      for (final token in knownOverflowTokens) {
        expect(FrosthavenConverter.shouldOverflow(false, token, true), isFalse);
      }
    });

    test('unknown token returns false even in frosthavenStyle=true', () {
      expect(FrosthavenConverter.shouldOverflow(true, 'attack', true), isFalse);
      expect(FrosthavenConverter.shouldOverflow(true, 'move', true), isFalse);
      expect(FrosthavenConverter.shouldOverflow(true, '', true), isFalse);
    });

    test('token containing "poison" returns true (contains check)', () {
      expect(
          FrosthavenConverter.shouldOverflow(true, 'acid-poison', true), isTrue);
    });

    test('token containing "wound" returns true (contains check)', () {
      expect(
          FrosthavenConverter.shouldOverflow(true, 'wound-infect', true), isTrue);
    });
  });
}
