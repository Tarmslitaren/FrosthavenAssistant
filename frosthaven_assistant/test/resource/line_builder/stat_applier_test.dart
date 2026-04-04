import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/line_builder/stat_applier.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../command/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    SetLevelCommand(1, null).execute();
    SetCampaignCommand('Jaws of the Lion').execute();
    AddMonsterCommand('Zealot', 1, false).execute();
  });

  // Zealot level 1: normal attack=2 move=2 range=0, elite attack=3 move=2 range=0

  Monster zealot() =>
      getIt<GameState>().currentList.firstWhere((e) => e.id == 'Zealot')
          as Monster;

  // ── plain text – no formulas ──────────────────────────────────────────────

  group('StatApplier.applyMonsterStats – plain text', () {
    test('line with no formula is returned unchanged', () {
      final result =
          StatApplier.applyMonsterStats('Move 3', '', zealot(), false);
      expect(result, equals(['Move 3']));
    });

    test('line with pure text and token name unchanged', () {
      final result =
          StatApplier.applyMonsterStats('%attack%', '', zealot(), false);
      expect(result, equals(['%attack%']));
    });

    test('single digit with no preceding token is treated as plain text', () {
      // "3" alone at position 0 is a plain number; no token → calculateFormula("3")=3
      // but length must be >2 or formula must have lastToken; "3" alone is length 1 → not applied
      final result =
          StatApplier.applyMonsterStats('3', '', zealot(), false);
      expect(result, equals(['3']));
    });
  });

  // ── forceShowAll=false with no standees ──────────────────────────────────

  group('StatApplier.applyMonsterStats – no standees (forceShowAll=false)', () {
    test('%attack% +0 unchanged when no standees and forceShowAll=false', () {
      // showNormal=false, showElite=false → line returned as-is
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), false);
      expect(result, equals(['%attack% +0']));
    });

    test('%move% +1 unchanged when no standees and forceShowAll=false', () {
      final result = StatApplier.applyMonsterStats(
          '%move% +1', '', zealot(), false);
      expect(result, equals(['%move% +1']));
    });
  });

  // ── forceShowAll=true: attack formula ─────────────────────────────────────

  group('StatApplier.applyMonsterStats – forceShowAll attack', () {
    test('%attack% +0 with forceShowAll splits into multiple results', () {
      // normal attack=2, elite attack=3; formula "+0" → normal=2, elite=3
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), true);
      expect(result.length, greaterThan(1));
    });

    test('normal result contains the computed normal attack value', () {
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), true);
      // First string contains "%attack% 2/" (the normal result)
      expect(result.first, contains('2'));
    });

    test('elite result contains the computed elite attack value', () {
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), true);
      // Second string is the elite part starting with "!"
      final elite = result.firstWhere((s) => s.startsWith('!'));
      expect(elite, contains('3'));
    });

    test('%attack% +1 adds 1 to both normal and elite values', () {
      // normal=2+1=3, elite=3+1=4
      final result = StatApplier.applyMonsterStats(
          '%attack% +1', '', zealot(), true);
      expect(result.first, contains('3'));
      final elite = result.firstWhere((s) => s.startsWith('!'));
      expect(elite, contains('4'));
    });

    test('%attack% -1 subtracts 1 (clamps to 0 if negative)', () {
      // normal=2-1=1, elite=3-1=2
      final result = StatApplier.applyMonsterStats(
          '%attack% -1', '', zealot(), true);
      expect(result.first, contains('1'));
      final elite = result.firstWhere((s) => s.startsWith('!'));
      expect(elite, contains('2'));
    });
  });

  // ── forceShowAll=true: move formula ──────────────────────────────────────

  group('StatApplier.applyMonsterStats – forceShowAll move', () {
    test('%move% +0 yields Zealot move value (2)', () {
      final result = StatApplier.applyMonsterStats(
          '%move% +0', '', zealot(), true);
      expect(result.first, contains('2'));
    });

    test('%move% +2 yields Zealot move+2 (4) for both', () {
      // normal move=2+2=4, elite move=2+2=4
      final result = StatApplier.applyMonsterStats(
          '%move% +2', '', zealot(), true);
      expect(result.first, contains('4'));
    });
  });

  // ── with standees present (forceShowAll=false) ───────────────────────────

  group('StatApplier.applyMonsterStats – with actual standees', () {
    test('normal standee present → shows normal stat', () {
      AddStandeeCommand(1, null, 'Zealot', MonsterType.normal, false)
          .execute();
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), false);
      // showNormal=true, showElite=false
      expect(result.first, contains('2'));
      // No elite part
      expect(result.every((s) => !s.contains('3')), isTrue);
      getIt<GameState>().undo();
    });

    test('elite standee present → shows both normal and elite stat', () {
      AddStandeeCommand(1, null, 'Zealot', MonsterType.elite, false)
          .execute();
      final result = StatApplier.applyMonsterStats(
          '%attack% +0', '', zealot(), false);
      // showElite=true → split output with both values
      expect(result.length, greaterThan(1));
      expect(result.any((s) => s.contains('3')), isTrue);
      getIt<GameState>().undo();
    });
  });

  // ── formula without preceding token ──────────────────────────────────────

  group('StatApplier.applyMonsterStats – standalone formula', () {
    test('C+L formula (≥3 chars, no token) is evaluated', () {
      // With level=1 and 0 characters (C clamped to 2): C+L = 2+1 = 3
      final result = StatApplier.applyMonsterStats(
          'C+L health', '', zealot(), false);
      expect(result.first, contains('3'));
    });

    test('plain number ≥3 digits is evaluated as formula', () {
      // "100" is 3 chars and contains only digits; calculateFormula("100")=100
      final result = StatApplier.applyMonsterStats(
          '100 damage', '', zealot(), false);
      expect(result.first, contains('100'));
    });
  });

  // ── shield from attribute ─────────────────────────────────────────────────

  group('StatApplier.applyMonsterStats – shield token', () {
    setUp(() {
      getIt<GameState>().clearList();
      SetLevelCommand(1, null).execute();
      SetCampaignCommand('Jaws of the Lion').execute();
      // Black Sludge has %shield% 1 in both normal and elite at level 1
      AddMonsterCommand('Black Sludge', 1, false).execute();
    });

    Monster blackSludge() =>
        getIt<GameState>().currentList.firstWhere((e) => e.id == 'Black Sludge')
            as Monster;

    test('%shield% +0 with Black Sludge yields shield value 1', () {
      final result = StatApplier.applyMonsterStats(
          '%shield% +0', '', blackSludge(), true);
      expect(result.first, contains('1'));
    });
  });
}
