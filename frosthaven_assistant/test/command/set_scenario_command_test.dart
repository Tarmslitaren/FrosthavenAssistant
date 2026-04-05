import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_condition_command.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_xp_command.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/commands/show_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'test_helpers.dart';

// Test data availability:
//   JotL monsters: Zealot, Chaos Demon, Blood Tumor, Rat Monstrosity, Black Sludge, Vermling Raider
//   FH monsters:   Ancient Artillery (FH)
//   JotL scenarios usable: #5 (Zealot/Chaos Demon/Blood Tumor), #6 (Rat Monstrosity/Black Sludge)
//   FH scenarios usable:   #0 Howling in the Snow (Ancient Artillery FH), custom

void main() {
  setUpAll(() async {
    await setUpGame();
  });

  setUp(() {
    getIt<GameState>().clearList();
    AddCharacterCommand('Blinkblade', 'Frosthaven', 'apan', 1).execute();
    SetCampaignCommand('Jaws of the Lion').execute();
  });

  // ---------------------------------------------------------------------------
  // describe()
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand describe()', () {
    test('returns "Set Scenario" when section is false', () {
      expect(SetScenarioCommand('#5 A Deeper Understanding', false).describe(),
          'Set Scenario');
    });

    test('returns "Add Section" when section is true', () {
      expect(SetScenarioCommand('#door', true).describe(), 'Add Section');
    });
  });

  // ---------------------------------------------------------------------------
  // Basic scenario setup
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand basic scenario setup', () {
    test('sets scenario name on game state', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().scenario.value, '#5 A Deeper Understanding');
    });

    test('loads correct number of monsters and ability decks', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final gs = getIt<GameState>();
      // #5 has Zealot, Chaos Demon, Blood Tumor
      expect(gs.currentList.whereType<Monster>().length, 3);
      expect(gs.currentAbilityDecks.length, 3);
      checkSaveState();
    });

    test('round is reset to 1', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().round.value, 1);
    });

    test('totalRounds is reset to 1', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().totalRounds.value, 1);
    });

    test('round state is set to chooseInitiative', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().roundState.value, RoundState.chooseInitiative);
    });

    test('showAllyDeck is false for scenario with no AllyDeck rule', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().showAllyDeck.value, isFalse);
    });

    test('no loot deck for JotL scenario', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().lootDeck.cardCount.value, 0);
    });

    test('loot deck populated for Frosthaven scenario with loot', () {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('#0 Howling in the Snow', false).execute();
      expect(getIt<GameState>().lootDeck.cardCount.value, greaterThan(0));
      checkSaveState();
    });

    test('scenarioSectionsAdded is empty on fresh scenario', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().scenarioSectionsAdded, isEmpty);
    });

    test('scenarioSpecialRules is populated for scenario with rules', () {
      // #6 has Allies and Objective rules
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      expect(getIt<GameState>().scenarioSpecialRules, isNotEmpty);
    });

    test('ability decks have cards in draw pile after scenario load', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      for (final deck in getIt<GameState>().currentAbilityDecks) {
        expect(deck.drawPile.isNotEmpty, isTrue);
      }
    });

    test('modifier deck discard pile is empty after scenario load', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().modifierDeck.discardPile.isEmpty, isTrue);
    });

    test('modifier deck draw pile is not empty after scenario load', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().modifierDeck.drawPile.isNotEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Character state reset
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand character state reset', () {
    test('character initiative is reset to 0', () {
      final character = getIt<GameState>().currentList.first as Character;
      SetInitCommand(character.id, 42).execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final after = getIt<GameState>().currentList.first as Character;
      expect(after.characterState.initiative.value, 0);
    });

    test('character xp is reset to 0', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final character =
          getIt<GameState>().currentList.first as Character;
      ChangeXPCommand(10, character.id, character.id).execute();
      // Load a different scenario to trigger reset
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final after = getIt<GameState>()
          .currentList
          .firstWhere((e) =>
              e is Character &&
              !GameMethods.isObjectiveOrEscort((e as Character).characterClass))
          as Character;
      expect(after.characterState.xp.value, 0);
    });

    test('character conditions are cleared', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final character = getIt<GameState>().currentList.first as Character;
      AddConditionCommand(Condition.poison, character.id, character.id)
          .execute();
      expect(character.characterState.conditions.value,
          contains(Condition.poison));

      SetScenarioCommand('#6 Corrupted Research', false).execute();

      final after = getIt<GameState>()
          .currentList
          .firstWhere((e) =>
              e is Character &&
              !GameMethods.isObjectiveOrEscort((e as Character).characterClass))
          as Character;
      expect(after.characterState.conditions.value, isEmpty);
    });

    test('character health is restored to max on reset', () {
      final character = getIt<GameState>().currentList.first as Character;
      final maxHp = character.characterState.maxHealth.value;
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final after = getIt<GameState>().currentList.first as Character;
      expect(after.characterState.health.value, maxHp);
    });

    test('normal characters are preserved across scenario changes', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final characters = getIt<GameState>().currentList.whereType<Character>();
      expect(
          characters.any(
              (c) => !GameMethods.isObjectiveOrEscort(c.characterClass)),
          isTrue);
    });

    test('objectives from previous scenario are removed on new scenario', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      expect(
          getIt<GameState>().currentList.any((item) =>
              item is Character &&
              GameMethods.isObjectiveOrEscort(item.characterClass)),
          isTrue);

      SetScenarioCommand('#5 A Deeper Understanding', false).execute();

      expect(
          getIt<GameState>().currentList.any((item) =>
              item is Character &&
              GameMethods.isObjectiveOrEscort(item.characterClass)),
          isFalse);
    });

    test('previous scenario monsters are replaced on new scenario', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      // #5 has Zealot
      expect(
          getIt<GameState>()
              .currentList
              .whereType<Monster>()
              .any((m) => m.id == 'Zealot'),
          isTrue);

      SetScenarioCommand('#6 Corrupted Research', false).execute();

      // #6 has Rat Monstrosity and Black Sludge, not Zealot
      expect(
          getIt<GameState>()
              .currentList
              .whereType<Monster>()
              .any((m) => m.id == 'Zealot'),
          isFalse,
          reason: 'Zealot from #5 should not be present in #6');
      expect(
          getIt<GameState>()
              .currentList
              .whereType<Monster>()
              .any((m) => m.id == 'Rat Monstrosity'),
          isTrue);
    });

    test('previous ability decks are replaced on new scenario', () {
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final decksAfterFirst =
          getIt<GameState>().currentAbilityDecks.map((d) => d.name).toSet();

      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final decksAfterSecond =
          getIt<GameState>().currentAbilityDecks.map((d) => d.name).toSet();

      expect(decksAfterSecond, isNot(equals(decksAfterFirst)));
    });
  });

  // ---------------------------------------------------------------------------
  // Element reset
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand element reset', () {
    test('all elements are reset to inert on new scenario', () {
      ImbueElementCommand(Elements.fire, false).execute();
      ImbueElementCommand(Elements.ice, false).execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      final elementState = getIt<GameState>().elementState;
      for (final element in Elements.values) {
        expect(elementState[element], ElementState.inert,
            reason: '${element.name} should be inert');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Ally / Ally deck rules
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand ally rules', () {
    // #6 Corrupted Research (JotL): "Allies": ["Rat Monstrosity"]
    test('monsters listed in Allies rule are marked isAlly', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final ratMonstrosity = getIt<GameState>()
          .currentList
          .whereType<Monster>()
          .firstWhere((m) => m.id == 'Rat Monstrosity');
      expect(ratMonstrosity.isAlly, isTrue);
    });

    test('monsters not in Allies rule are not marked isAlly', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final blackSludge = getIt<GameState>()
          .currentList
          .whereType<Monster>()
          .firstWhere((m) => m.id == 'Black Sludge');
      expect(blackSludge.isAlly, isFalse);
    });

    test('shouldShowAlliesDeck returns true when allied monsters are present',
        () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      expect(GameMethods.shouldShowAlliesDeck(), isTrue);
    });

    test(
        'showAllyDeck flag stays false when allies come from "Allies" rule '
        'rather than "AllyDeck" rule', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      // The Allies rule marks monsters as isAlly but does NOT set showAllyDeck
      expect(getIt<GameState>().showAllyDeck.value, isFalse);
    });

    test('showAllyDeck is reset to false when loading a scenario without AllyDeck rule',
        () {
      // Start from a state where showAllyDeck is true (set manually via ShowAllyDeckCommand)
      ShowAllyDeckCommand().execute();
      SetScenarioCommand('#5 A Deeper Understanding', false).execute();
      expect(getIt<GameState>().showAllyDeck.value, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Objective special rule
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand Objective special rule', () {
    test('all 7 objectives from #6 Corrupted Research are added to list', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final objectives = getIt<GameState>().currentList.where((item) =>
          item is Character &&
          GameMethods.isObjectiveOrEscort(item.characterClass));
      expect(objectives.length, 7);
      checkSaveState();
    });

    test('objective display names match scenario data (Growth 1–7)', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      final names = getIt<GameState>()
          .currentList
          .whereType<Character>()
          .where((c) => GameMethods.isObjectiveOrEscort(c.characterClass))
          .map((c) => c.characterState.display.value)
          .toSet();
      for (int i = 1; i <= 7; i++) {
        expect(names, contains('Growth $i'));
      }
    });

    test('objectives have positive health', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      for (final obj in getIt<GameState>()
          .currentList
          .whereType<Character>()
          .where((c) => GameMethods.isObjectiveOrEscort(c.characterClass))) {
        expect(obj.characterState.health.value, greaterThan(0));
      }
    });

    test('objectives are IsObjectiveOrEscort characters', () {
      SetScenarioCommand('#6 Corrupted Research', false).execute();
      for (final obj in getIt<GameState>()
          .currentList
          .whereType<Character>()
          .where((c) => GameMethods.isObjectiveOrEscort(c.characterClass))) {
        expect(GameMethods.isObjectiveOrEscort(obj.characterClass), isTrue);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // undo() coverage
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand undo', () {
    test('undo does not throw', () {
      final gs = getIt<GameState>();
      gs.action(SetScenarioCommand('#5 A Deeper Understanding', false));
      expect(() => gs.undo(), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // Custom scenarios
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand custom scenarios', () {
    test('Frosthaven custom scenario creates a loot deck', () {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('custom', false).execute();
      expect(getIt<GameState>().lootDeck.cardCount.value, greaterThan(0));
      checkSaveState();
    });

    test('non-Frosthaven custom scenario has no loot deck', () {
      SetCampaignCommand('Jaws of the Lion').execute();
      SetScenarioCommand('custom', false).execute();
      expect(getIt<GameState>().lootDeck.cardCount.value, 0);
    });

    test('custom scenario has no monsters', () {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('custom', false).execute();
      expect(getIt<GameState>().currentList.whereType<Monster>(), isEmpty);
    });

    test('custom scenario has no ability decks', () {
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand('custom', false).execute();
      expect(getIt<GameState>().currentAbilityDecks, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Sections
  // Test data: FH '#0 Howling in the Snow' has one test section: '#0.1 The Frozen Depths'
  // ---------------------------------------------------------------------------
  group('SetScenarioCommand sections', () {
    const String baseScenario = '#0 Howling in the Snow';
    const String sectionName = '#0.1 The Frozen Depths';

    setUp(() {
      getIt<GameState>().clearList();
      AddCharacterCommand('Blinkblade', 'Frosthaven', 'apan', 1).execute();
      SetCampaignCommand('Frosthaven').execute();
      SetScenarioCommand(baseScenario, false).execute();
    });

    test('section name is tracked in scenarioSectionsAdded', () {
      SetScenarioCommand(sectionName, true).execute();
      expect(getIt<GameState>().scenarioSectionsAdded, contains(sectionName));
      checkSaveState();
    });

    test('adding the same section twice records it twice', () {
      SetScenarioCommand(sectionName, true).execute();
      SetScenarioCommand(sectionName, true).execute();
      expect(
          getIt<GameState>()
              .scenarioSectionsAdded
              .where((s) => s == sectionName)
              .length,
          2);
    });

    test('scenarioSectionsAdded is cleared when a new base scenario is loaded',
        () {
      SetScenarioCommand(sectionName, true).execute();
      expect(getIt<GameState>().scenarioSectionsAdded, isNotEmpty);

      SetScenarioCommand('#0 Howling in the Snow', false).execute();

      expect(getIt<GameState>().scenarioSectionsAdded, isEmpty);
    });

    test('adding a section does not remove previously-added monsters', () {
      // Manually add a known monster after loading the base scenario
      AddMonsterCommand('Ancient Artillery (FH)', 1, false).execute();
      final monstersBefore =
          getIt<GameState>().currentList.whereType<Monster>().length;

      SetScenarioCommand(sectionName, true).execute();

      expect(getIt<GameState>().currentList.whereType<Monster>().length,
          greaterThanOrEqualTo(monstersBefore));
    });

    test('section does not reset round or scenario name', () {
      final roundBefore = getIt<GameState>().round.value;
      final scenarioBefore = getIt<GameState>().scenario.value;
      SetScenarioCommand(sectionName, true).execute();
      expect(getIt<GameState>().round.value, roundBefore);
      expect(getIt<GameState>().scenario.value, scenarioBefore);
    });
  });
}
