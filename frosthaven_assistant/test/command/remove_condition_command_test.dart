// ignore_for_file: no-magic-number, avoid-late-keyword

import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/remove_condition_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

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

  group('RemoveConditionCommand', () {
    test('should remove a condition from a character', () {
      AddConditionCommand(Condition.poison, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();
      expect(character.characterState.conditions.value,
          contains(Condition.poison));

      RemoveConditionCommand(Condition.poison, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();

      expect(character.characterState.conditions.value,
          isNot(contains(Condition.poison)));
      checkSaveState();
    });

    test('should remove a condition from a monster instance', () {
      AddConditionCommand(Condition.wound, monsterInstance.getId(), monster.id,
              gameState: getIt<GameState>())
          .execute();
      expect(monsterInstance.conditions.value, contains(Condition.wound));

      RemoveConditionCommand(
              Condition.wound, monsterInstance.getId(), monster.id,
              gameState: getIt<GameState>())
          .execute();

      expect(
          monsterInstance.conditions.value, isNot(contains(Condition.wound)));
    });

    test('should decrement chill counter when removing chill', () {
      AddConditionCommand(Condition.chill, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();
      AddConditionCommand(Condition.chill, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();
      expect(character.characterState.chill.value, 2);

      RemoveConditionCommand(Condition.chill, character.id, character.id,
              gameState: getIt<GameState>())
          .execute();

      expect(character.characterState.chill.value, 1);
    });

    test('describe should return correct string', () {
      final command = RemoveConditionCommand(
          Condition.stun, character.id, character.id,
          gameState: getIt<GameState>());
      expect(command.describe(), 'Remove condition: stun');
    });
  });
}
