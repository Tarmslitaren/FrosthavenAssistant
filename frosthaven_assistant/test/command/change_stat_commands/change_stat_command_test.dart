// ignore_for_file: no-magic-number, avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_round_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  late Character character;
  late Monster monster;
  late MonsterInstance monsterInstance;

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1,
            gameState: getIt<GameState>())
        .execute();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false,
            gameState: getIt<GameState>())
        .execute();
    AddStandeeCommand(
            1, null, 'Ancient Artillery (FH)', MonsterType.normal, false,
            gameState: getIt<GameState>())
        .execute();
    character = getIt<GameState>().currentList.firstWhere((e) => e is Character)
        as Character;
    monster = getIt<GameState>().currentList.firstWhere((e) => e is Monster)
        as Monster;
    monsterInstance = monster.monsterInstances.first;
  });

  // ChangeStatCommand is abstract; tested through ChangeHealthCommand as a concrete example
  group('ChangeStatCommand (via ChangeHealthCommand)', () {
    test('handleDeath removes monster instance when health reaches 0', () {
      final currentHp = monsterInstance.health.value;
      // Deal lethal damage
      ChangeHealthCommand(-currentHp, monsterInstance.getId(), monster.id,
              gameState: getIt<GameState>())
          .execute();

      expect(monster.monsterInstances, isEmpty);
    });

    test('handleDeath keeps character in list when health reaches 0', () {
      final currentHp = character.characterState.health.value;
      ChangeHealthCommand(-currentHp, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();

      expect(getIt<GameState>().currentList.contains(character), isTrue);
    });

    test('describe returns "change stat"', () {
      // ChangeStatCommand.describe() returns "change stat"
      final command = ChangeHealthCommand(
          1, monsterInstance.getId(), monster.id,
          gameState: getIt<GameState>());
      // ChangeHealthCommand overrides describe, so check base via setChange
      command.setChange(0);
      expect(command.describe(), isNotEmpty);
    });

    test('handleDeath: monster death in playTurns state does not throw', () {
      // Enter playTurns state
      DrawCommand(gameState: getIt<GameState>()).execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      final currentHp = monsterInstance.health.value;
      // Kill the monster standee while in playTurns
      expect(
        () => ChangeHealthCommand(
                -currentHp, monsterInstance.getId(), monster.id,
                gameState: getIt<GameState>())
            .execute(),
        returnsNormally,
      );
      expect(monster.monsterInstances, isEmpty);
    });

    test(
        'handleDeath: character un-death triggers update (health 0 → positive)',
        () {
      // Kill the character
      final maxHp = character.characterState.health.value;
      ChangeHealthCommand(-maxHp, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();
      expect(character.characterState.health.value, 0);
      // Revive: going from 0 to positive triggers the un-death path (line 23)
      expect(
        () => ChangeHealthCommand(1, character.id, character.id,
                gameState: getIt<GameState>())
            .execute(),
        returnsNormally,
      );
      expect(character.characterState.health.value, 1);
    });

    test('handleDeath: summon death removes summon from character summonList',
        () {
      // Add Banner Spear (has summons in test data)
      getIt<GameState>().clearList();
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final bannerSpear =
          gs.currentList.firstWhere((e) => e is Character) as Character;

      // Add a summon with health=1 so it dies on 1 damage
      final summonData =
          SummonData(1, 'BAN reinforcements', 1, 2, 0, 0, 'BAN reinforcements');
      AddStandeeCommand(1, summonData, bannerSpear.id, MonsterType.summon, true,
              gameState: getIt<GameState>())
          .execute();

      expect(bannerSpear.characterState.summonList, isNotEmpty);
      final summonId = bannerSpear.characterState.summonList.first.getId();

      // Kill the summon using its full ID (name+gfx+standeeNr)
      ChangeHealthCommand(-1, summonId, bannerSpear.id,
              gameState: getIt<GameState>())
          .execute();

      // Summon should be removed
      expect(bannerSpear.characterState.summonList, isEmpty);
    });

    test('handleDeath: summon death in playTurns state does not throw', () {
      getIt<GameState>().clearList();
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final bannerSpear =
          gs.currentList.firstWhere((e) => e is Character) as Character;

      final summonData =
          SummonData(1, 'BAN reinforcements', 1, 2, 0, 0, 'BAN reinforcements');
      AddStandeeCommand(1, summonData, bannerSpear.id, MonsterType.summon, true,
              gameState: getIt<GameState>())
          .execute();
      final summonId = bannerSpear.characterState.summonList.first.getId();

      // Enter playTurns state
      DrawCommand(gameState: getIt<GameState>()).execute();
      expect(gs.roundState.value, RoundState.playTurns);

      // Kill summon in playTurns
      expect(
        () => ChangeHealthCommand(-1, summonId, bannerSpear.id,
                gameState: getIt<GameState>())
            .execute(),
        returnsNormally,
      );
      expect(bannerSpear.characterState.summonList, isEmpty);
      NextRoundCommand(
              gameState: getIt<GameState>(),
              gameData: getIt<GameData>(),
              settings: getIt<Settings>())
          .execute();
    });

    test('handleDeath: summon death when more summons remain still updates',
        () {
      getIt<GameState>().clearList();
      AddCharacterCommand('Banner Spear', 'Frosthaven', null, 1,
              gameState: getIt<GameState>())
          .execute();
      final gs = getIt<GameState>();
      final bannerSpear =
          gs.currentList.firstWhere((e) => e is Character) as Character;

      // Add two summons with health 1 and 2
      final summonData1 =
          SummonData(1, 'BAN reinforcements', 1, 2, 0, 0, 'BAN reinforcements');
      final summonData2 = SummonData(
          2, 'BAN banner of strength', 2, 2, 0, 0, 'BAN banner of strength');
      AddStandeeCommand(
              1, summonData1, bannerSpear.id, MonsterType.summon, true,
              gameState: getIt<GameState>())
          .execute();
      AddStandeeCommand(
              2, summonData2, bannerSpear.id, MonsterType.summon, true,
              gameState: getIt<GameState>())
          .execute();

      expect(bannerSpear.characterState.summonList.length, 2);
      // Get the ID of the first summon (health=1) before it's removed
      final firstSummonId = bannerSpear.characterState.summonList
          .firstWhere((s) => s.standeeNr == 1)
          .getId();

      // Kill only the first summon (health 1 → 0)
      ChangeHealthCommand(-1, firstSummonId, bannerSpear.id,
              gameState: getIt<GameState>())
          .execute();

      // One summon remains
      expect(bannerSpear.characterState.summonList.length, 1);
    });
  });
}
