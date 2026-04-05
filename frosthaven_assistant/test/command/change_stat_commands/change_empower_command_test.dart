import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_empower_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
    AddMonsterCommand("Zealot", 1, false).execute();
    AddStandeeCommand(1, null, "Zealot", MonsterType.normal, false).execute();
  });

  group('ChangeEmpowerCommand', () {
    test('should add an empowerment to a character', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      final command =
          ChangeEmpowerCommand(1, "in-empower", character.id, character.id);
      final initialEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      expect(finalEmpowerCount, initialEmpowerCount + 1);
      checkSaveState();
    });

    test('should remove an empowerment from a character', () {
      // Arrange
      final character = getIt<GameState>().currentList.first as Character;
      ChangeEmpowerCommand(1, "in-empower", character.id, character.id)
          .execute(); // Add an empowerment first
      final initialEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      final command =
          ChangeEmpowerCommand(-1, "in-empower", character.id, character.id);

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount = character.characterState.modifierDeck
          .getRemovable("in-empower")
          .value;
      expect(finalEmpowerCount, initialEmpowerCount - 1);
      checkSaveState();
    });

    test('should add an empowerment to a monster instance', () {
      // Arrange
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final monsterInstance = monster.monsterInstances.first;
      final command = ChangeEmpowerCommand(
          1, "in-empower", monster.id, monsterInstance.getId());
      final initialEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      expect(finalEmpowerCount, initialEmpowerCount + 1);
      checkSaveState();
    });

    test('should remove an empowerment from a monster instance', () {
      // Arrange
      final monster = getIt<GameState>()
          .currentList
          .firstWhere((e) => e is Monster) as Monster;
      final monsterInstance = monster.monsterInstances.first;
      ChangeEmpowerCommand(1, "in-empower", monster.id, monsterInstance.getId())
          .execute(); // Add an empowerment first
      final initialEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      final command = ChangeEmpowerCommand(
          -1, "in-empower", monster.id, monsterInstance.getId());

      // Act
      command.execute();

      // Assert
      final finalEmpowerCount =
          getIt<GameState>().modifierDeck.getRemovable("in-empower").value;
      expect(finalEmpowerCount, initialEmpowerCount - 1);
      checkSaveState();
    });

    test('describe should return correct string for adding empowerment', () {
      // Arrange
      final command =
          ChangeEmpowerCommand(1, "in-empower", 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Add Empower');
    });

    test('describe should return correct string for removing empowerment', () {
      // Arrange
      final command =
          ChangeEmpowerCommand(-1, "in-empower", 'Blinkblade', 'Blinkblade');

      // Act & Assert
      expect(command.describe(), 'Remove Empower');
    });

    test('undo does not throw', () {
      final gs = getIt<GameState>();
      final character = gs.currentList.first as Character;
      gs.action(ChangeEmpowerCommand(1, "in-empower", character.id, character.id));
      expect(() => gs.undo(), returnsNormally);
    });

    test('.deck() named constructor targets the given deck directly', () {
      final deck = getIt<GameState>().modifierDeck;
      final before = deck.getRemovable("in-empower").value;
      ChangeEmpowerCommand.deck(deck, "in-empower").execute();
      // change defaults to 0 for .deck() constructor, so value unchanged
      expect(deck.getRemovable("in-empower").value, before);
    });

    test('ally monster owner uses modifierDeckAllies', () {
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', '', 1).execute();
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      // Rat Monstrosity is marked isAlly in #6
      final gs = getIt<GameState>();
      final ratMonstrosity = gs.currentList
          .whereType<Monster>()
          .firstWhere((m) => m.id == 'Rat Monstrosity');
      expect(ratMonstrosity.isAlly, isTrue);

      final alliesDeckBefore =
          gs.modifierDeckAllies.getRemovable("in-empower").value;
      ChangeEmpowerCommand(1, "in-empower", ratMonstrosity.id, ratMonstrosity.id)
          .execute();
      expect(gs.modifierDeckAllies.getRemovable("in-empower").value,
          alliesDeckBefore + 1);
    });
  });
}
