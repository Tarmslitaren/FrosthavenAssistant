// ignore_for_file: no-magic-number

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_box_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_stat_card_view_model.dart';
import 'package:frosthaven_assistant/Layout/view_models/monster_widget_view_model.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
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
  });

  Monster addArtillery() {
    AddMonsterCommand('Ancient Artillery (FH)', 1, false,
            gameState: getIt<GameState>())
        .execute();
    return getIt<GameState>()
        .currentList
        .firstWhere((e) => e is Monster) as Monster;
  }

  // ── MonsterWidgetViewModel ─────────────────────────────────────────────────

  group('MonsterWidgetViewModel.isGrayScale', () {
    test('true when monster has no active standees and is not active', () {
      final monster = addArtillery();
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      // No standees added → not active → gray
      expect(vm.isGrayScale, isTrue);
      getIt<GameState>().undo();
    });

    test('false when monster is active (standee added)', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.isGrayScale, isFalse);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('true when turn is done in playTurns', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      (monster.turnState as ValueNotifier<TurnsState>).value = TurnsState.done;
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.isGrayScale, isTrue);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('false when turn is done but in chooseInitiative', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.chooseInitiative;
      (monster.turnState as ValueNotifier<TurnsState>).value = TurnsState.done;
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.isGrayScale, isFalse);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  group('MonsterWidgetViewModel.showTurnTap', () {
    test('false in chooseInitiative', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.showTurnTap, isFalse);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('true in playTurns with instances', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.showTurnTap, isTrue);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('false in playTurns with no instances and not active', () {
      final monster = addArtillery();
      (getIt<GameState>().roundState as ValueNotifier<RoundState>).value =
          RoundState.playTurns;
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.showTurnTap, isFalse);
      getIt<GameState>().undo();
    });
  });

  group('MonsterWidgetViewModel.endTurn', () {
    test('dispatches TurnDoneCommand', () {
      final monster = addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      AddCharacterCommand('Blinkblade', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      DrawCommand(gameState: getIt<GameState>()).execute();

      // Set monster as current
      (monster.turnState as ValueNotifier<TurnsState>).value =
          TurnsState.current;
      MonsterWidgetViewModel(monster, gameState: getIt<GameState>()).endTurn();
      expect(monster.turnState.value, TurnsState.done);

      getIt<GameState>().undo(); // undo draw
      getIt<GameState>().undo(); // undo add character
      getIt<GameState>().undo(); // undo add standee
      getIt<GameState>().undo(); // undo add monster
    });
  });

  group('MonsterWidgetViewModel notifiers', () {
    test('updateList listenable is exposed', () {
      final monster = addArtillery();
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.updateList, isNotNull);
      getIt<GameState>().undo();
    });

    test('monsterInstancesNotifier listenable is exposed', () {
      final monster = addArtillery();
      final vm = MonsterWidgetViewModel(monster, gameState: getIt<GameState>());
      expect(vm.monsterInstancesNotifier, isNotNull);
      getIt<GameState>().undo();
    });
  });

  // ── MonsterBoxViewModel ────────────────────────────────────────────────────

  group('MonsterBoxViewModel.color', () {
    test('white for normal standee', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.color, Colors.white);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('yellow for elite standee', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.elite, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.color, Colors.yellow);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  group('MonsterBoxViewModel.characterId', () {
    test('null when ownerId equals standee name', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      // ownerId matches data.name → characterId should be null
      final vm = MonsterBoxViewModel(standee,
          ownerId: standee.name,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.characterId, isNull);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('returns ownerId when different from standee name (summon)', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      const summonOwner = 'SomeCharacterId';
      final vm = MonsterBoxViewModel(standee,
          ownerId: summonOwner,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.characterId, summonOwner);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  group('MonsterBoxViewModel.monsterId', () {
    test('returns monster id when found in currentList', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.monsterId, monster.id);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('returns null when standee name not in currentList', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      // Clear list so standee.name is no longer present
      getIt<GameState>().clearList();
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.monsterId, isNull);
    });
  });

  group('MonsterBoxViewModel.isAlive', () {
    test('true when health > 0', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      expect(standee.health.value, greaterThan(0));
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.isAlive, isTrue);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('false when health is 0', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      (standee.health as ValueNotifier<int>).value = 0;
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.isAlive, isFalse);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  group('MonsterBoxViewModel.ownerIsCurrent', () {
    test('true when owner is not in list (defaults to true)', () {
      addArtillery();
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final standee = monster.monsterInstances.first;
      final vm = MonsterBoxViewModel(standee,
          ownerId: 'NonexistentId',
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.ownerIsCurrent, isTrue);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });

    test('false when owner turnState is done', () {
      addArtillery();
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      AddStandeeCommand(
              1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
              gameState: getIt<GameState>())
          .execute();
      (monster.turnState as ValueNotifier<TurnsState>).value = TurnsState.done;
      final standee = monster.monsterInstances.first;
      final vm = MonsterBoxViewModel(standee,
          ownerId: monster.id,
          gameState: getIt<GameState>(),
          settings: getIt<Settings>());
      expect(vm.ownerIsCurrent, isFalse);
      getIt<GameState>().undo();
      getIt<GameState>().undo();
    });
  });

  // ── MonsterStatCardViewModel ───────────────────────────────────────────────

  group('MonsterStatCardViewModel.isBoss', () {
    test('false for non-boss monster', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.isBoss, isFalse);
      getIt<GameState>().undo();
    });
  });

  group('MonsterStatCardViewModel.allStandeesOut', () {
    test('false when no standees added', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.allStandeesOut, isFalse);
      getIt<GameState>().undo();
    });
  });

  group('MonsterStatCardViewModel.resolveBossHealth', () {
    test('returns rawHealth unchanged for non-special values', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.resolveBossHealth('10'), '10');
      expect(vm.resolveBossHealth('42'), '42');
      getIt<GameState>().undo();
    });

    test('returns default "7" for Hollowpact when not in list', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.resolveBossHealth('Hollowpact'), '7');
      getIt<GameState>().undo();
    });

    test('returns default "36" for Incarnate when not in list', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.resolveBossHealth('Incarnate'), '36');
      getIt<GameState>().undo();
    });
  });

  group('MonsterStatCardViewModel notifiers', () {
    test('levelChanges listenable is exposed', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.levelChanges, isNotNull);
      getIt<GameState>().undo();
    });

    test('commandIndex listenable is exposed', () {
      final monster = addArtillery();
      final vm = MonsterStatCardViewModel(monster,
          gameState: getIt<GameState>(), settings: getIt<Settings>());
      expect(vm.commandIndex, isNotNull);
      getIt<GameState>().undo();
    });
  });
}
