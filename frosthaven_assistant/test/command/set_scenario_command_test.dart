import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  // We use a separate setUp function to reset the game state before each test.
  // This ensures that our tests are independent and not affecting each other.
  setUp(() {
    getIt<GameState>().clearList(); //todo: more thourough reset
    AddCharacterCommand('Blinkblade', 'Frosthaven', "apan", 1).execute();
    SetCampaignCommand("Jaws of the Lion");
  });

  group('SetScenarioCommand', () {
    test('correctly sets up a basic scenario', () {
      // Arrange
      final command = SetScenarioCommand('#5 A Deeper Understanding', false);

      // Act
      command.execute();

      // Assert
      final gameState = getIt<GameState>();
      // Scenario 5 has 3 monster types: Piranha Pig, Shrike Fiend, and Chaos Demon
      expect(gameState.currentList.whereType<Monster>().length, 3);
      expect(gameState.currentAbilityDecks.length, 3);
      expect(gameState.scenario.value, '#5 A Deeper Understanding');
      expect(gameState.round.value, 1);
      expect(gameState.totalRounds.value, 1);
      expect(gameState.showAllyDeck.value, isFalse);
      // This scenario has no specific loot deck
      expect(gameState.lootDeck.cardCount.value, 0);
      checkSaveState();
    });

    test('correctly adds a section to a scenario', () {
      // Arrange
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();

      final zealot = GameMethods.getCurrentMonsters()[0];
      //final zealotsBefore = zealot.monsterInstances.asList().length;

      // Act: Adding section 'door' to the scenario
      SetScenarioCommand('#door', true).execute();

      // Assert
      final gameState = getIt<GameState>();

      //final zealotsAfter = zealot.monsterInstances.asList().length;

      //expect(zealotsAfter, greaterThan(zealotsBefore));
      expect(gameState.scenarioSectionsAdded, contains('#door'));
      checkSaveState();
    });

    test('correctly handles special rules like AllyDeck and Objective', () {
      // Arrange: Scenario 19 is known to have an objective and require an ally deck
      final command = SetScenarioCommand('#6 Corrupted Research', false);

      // Act
      command.execute();

      // Assert
      final gameState = getIt<GameState>();
      final hasObjective = gameState.currentList.any((item) =>
          item is Character &&
          GameMethods.isObjectiveOrEscort(item.characterClass));
      expect(hasObjective, isTrue,
          reason: "Scenario should have an objective.");
      expect(GameMethods.shouldShowAlliesDeck(), isTrue,
          reason: "Scenario should show the ally deck.");
      checkSaveState();
    });

    test('setting a new scenario resets character and game state', () {
      // Arrange: Set up an initial state with a character and a scenario
      final character = getIt<GameState>().currentList.first as Character;

      SetInitCommand(character.id, 15).execute();
      ChangeXPCommand(15, character.id, character.id);
      //character.characterState.setXp(StateModifier(), 15)
      //character.characterState.setXp(StateModifier(), 15);
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();

      // Act: Set a new scenario
      SetScenarioCommand('#6 Corrupted Research', false).execute();

      // Assert: Verify that the state has been properly reset
      final gameState = getIt<GameState>();
      final characterAfter = gameState.currentList.first as Character;
      expect(gameState.scenario.value, '#6 Corrupted Research');
      expect(gameState.round.value, 1);
      expect(characterAfter.characterState.xp.value, 0);
      expect(characterAfter.characterState.initiative.value, 0);
      expect(characterAfter.characterState.conditions.value, isEmpty);
      checkSaveState();
    });

    test('custom scenarios have a random Frosthaven loot deck', () {
      // Arrange
      SetCampaignCommand("Frosthaven").execute();
      SetScenarioCommand('custom', false).execute();

      // Assert
      final gameState = getIt<GameState>();
      // For Frosthaven, a random loot deck is created for custom scenarios.
      expect(gameState.lootDeck.cardCount.value, greaterThan(0));
      checkSaveState();
    });

    test('describe method provides a correct description', () {
      // Arrange
      final command = SetScenarioCommand('#6 Corrupted Research', false);

      // Act & Assert
      expect(command.describe(), 'Set Scenario');
      checkSaveState();
    });
  });
}
//todo: these tests are not all encompassing. write more test
