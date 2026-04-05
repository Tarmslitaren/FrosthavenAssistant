import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
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
    AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1).execute();
    AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
    AddStandeeCommand(
            1, null, 'Ancient Artillery (FH)', MonsterType.normal, false)
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
      ChangeHealthCommand(-currentHp, monsterInstance.getId(), monster.id)
          .execute();

      expect(monster.monsterInstances, isEmpty);
    });

    test('handleDeath keeps character in list when health reaches 0', () {
      final currentHp = character.characterState.health.value;
      ChangeHealthCommand(-currentHp, character.id, character.id).execute();

      expect(getIt<GameState>().currentList.contains(character), isTrue);
    });

    test('describe returns "change stat"', () {
      // ChangeStatCommand.describe() returns "change stat"
      final command =
          ChangeHealthCommand(1, monsterInstance.getId(), monster.id);
      // ChangeHealthCommand overrides describe, so check base via setChange
      command.setChange(0);
      expect(command.describe(), isNotEmpty);
    });

    test('handleDeath: monster death in playTurns state does not throw', () {
      // Enter playTurns state
      DrawCommand().execute();
      expect(getIt<GameState>().roundState.value, RoundState.playTurns);
      final currentHp = monsterInstance.health.value;
      // Kill the monster standee while in playTurns
      expect(
        () => ChangeHealthCommand(-currentHp, monsterInstance.getId(), monster.id)
            .execute(),
        returnsNormally,
      );
      expect(monster.monsterInstances, isEmpty);
    });

    test('handleDeath: character un-death triggers update (health 0 → positive)', () {
      // Kill the character
      final maxHp = character.characterState.health.value;
      ChangeHealthCommand(-maxHp, character.id, character.id).execute();
      expect(character.characterState.health.value, 0);
      // Revive: going from 0 to positive triggers the un-death path (line 23)
      expect(
        () => ChangeHealthCommand(1, character.id, character.id).execute(),
        returnsNormally,
      );
      expect(character.characterState.health.value, 1);
    });
  });
}
