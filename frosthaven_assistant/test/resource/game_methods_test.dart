import 'package:flutter_test/flutter_test.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Resource/commands/add_character_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_monster_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_perk_command.dart';
import 'package:frosthaven_assistant/Resource/commands/add_standee_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_command.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_campaign_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_character_level_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_init_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_level_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_scenario_command.dart';
import 'package:frosthaven_assistant/Resource/commands/set_solo_command.dart';
import 'package:frosthaven_assistant/Resource/commands/show_ally_deck_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../command/test_helpers.dart';

void main() async {
  await setUpGame();

  group('GameMethods', () {
    group('getTrapValue', () {
      test('should return 2 + game level when level is 4', () {
        // Act: Call the method we are testing.
        SetLevelCommand(4, null).execute();
        final result = GameMethods.getTrapValue();

        // Assert: Check if the result is what we expect.
        expect(result, 6);
      });

      test('should return 2 when game level is 0', () {
        SetLevelCommand(0, null).execute();
        // Act
        final result = GameMethods.getTrapValue();

        // Assert
        expect(result, 2);
      });

      test('should return 9 when game level is 7', () {
        SetLevelCommand(7, null).execute();
        // Act
        final result = GameMethods.getTrapValue();

        // Assert
        expect(result, 9);
      });

      test('should bork when game level is out of bounds', () {
        expect(() => SetLevelCommand(77, null).execute(), throwsAssertionError);
      });

      test('should bork when game level is out of bounds low', () {
        expect(
            () => SetLevelCommand(-77, null).execute(), throwsAssertionError);
      });
    });

    group('getHazardValue', () {
      test('should return 1 + ceil(level / 3) for Frosthaven', () {
        getIt<Settings>().style.value = Style.frosthaven;
        SetLevelCommand(0, null).execute();
        expect(GameMethods.getHazardValue(), 1);
        SetLevelCommand(1, null).execute();
        expect(GameMethods.getHazardValue(), 2);
        SetLevelCommand(2, null).execute();
        expect(GameMethods.getHazardValue(), 2);
        SetLevelCommand(3, null).execute();
        expect(GameMethods.getHazardValue(), 2);
        SetLevelCommand(4, null).execute();
        expect(GameMethods.getHazardValue(), 3);
        SetLevelCommand(5, null).execute();
        expect(GameMethods.getHazardValue(), 3);
        SetLevelCommand(6, null).execute();
        expect(GameMethods.getHazardValue(), 3);
        SetLevelCommand(7, null).execute();
        expect(GameMethods.getHazardValue(), 4);
      });

      test('should return floor(trapValue / 2) for Gloomhaven', () {
        SetCampaignCommand("Gloomhaven").execute();
        getIt<Settings>().fhHazTerrainCalcInOGGloom.value = false;

        SetLevelCommand(0, null).execute();
        expect(GameMethods.getHazardValue(), 1);
        SetLevelCommand(1, null).execute();
        expect(GameMethods.getHazardValue(), 1);
        SetLevelCommand(2, null).execute();
        expect(GameMethods.getHazardValue(), 2);
        SetLevelCommand(3, null).execute();
        expect(GameMethods.getHazardValue(), 2);
        SetLevelCommand(4, null).execute();
        expect(GameMethods.getHazardValue(), 3);
        SetLevelCommand(5, null).execute();
        expect(GameMethods.getHazardValue(), 3);
        SetLevelCommand(6, null).execute();
        expect(GameMethods.getHazardValue(), 4);
        SetLevelCommand(7, null).execute();
        expect(GameMethods.getHazardValue(), 4);
      });
    });

    group('getXPValue', () {
      test('should return 4 + 2 * level', () {
        SetLevelCommand(0, null).execute();
        expect(GameMethods.getXPValue(), 4);
        SetLevelCommand(1, null).execute();
        expect(GameMethods.getXPValue(), 6);
        SetLevelCommand(7, null).execute();
        expect(GameMethods.getXPValue(), 18);
      });
    });

    group('getCoinValue', () {
      test('should return correct coin value for level', () {
        SetLevelCommand(0, null).execute();
        expect(GameMethods.getCoinValue(), 2);
        SetLevelCommand(1, null).execute();
        expect(GameMethods.getCoinValue(), 2);
        SetLevelCommand(2, null).execute();
        expect(GameMethods.getCoinValue(), 3);
        SetLevelCommand(3, null).execute();
        expect(GameMethods.getCoinValue(), 3);
        SetLevelCommand(4, null).execute();
        expect(GameMethods.getCoinValue(), 4);
        SetLevelCommand(5, null).execute();
        expect(GameMethods.getCoinValue(), 4);
        SetLevelCommand(6, null).execute();
        expect(GameMethods.getCoinValue(), 5);
        SetLevelCommand(7, null).execute();
        expect(GameMethods.getCoinValue(), 6);
      });
    });

    group('getRecommendedLevel', () {
      test('should return 1 if no characters', () {
        getIt<GameState>().clearList();

        expect(GameMethods.getRecommendedLevel(), 1);
      });

      test('should calculate recommended level for multiple characters', () {
        //getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        AddCharacterCommand('Banner Spear', 'Frosthaven', 'Banner Spear', 1)
            .execute();
        SetCharacterLevelCommand(3, 'Blinkblade').execute();
        SetCharacterLevelCommand(5, 'Banner Spear').execute();

        expect(GameMethods.getRecommendedLevel(), 2);
      });

      test('should calculate recommended level for solo', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        SetCharacterLevelCommand(3, 'Blinkblade').execute();
        SetSoloCommand(true).execute();

        expect(GameMethods.getRecommendedLevel(), 2);
      });
    });

    group('canDraw', () {
      test('should return false if no characters', () {
        getIt<GameState>().clearList();
        expect(GameMethods.canDraw(), isFalse);
      });

      test('should return true if noInit setting is true', () {
        getIt<Settings>().noInit.value = true;
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        expect(GameMethods.canDraw(), isTrue);
      });

      test('should return false if a character has no initiative', () {
        getIt<Settings>().noInit.value = false;
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        expect(GameMethods.canDraw(), isFalse);
      });

      test('should return true if all characters have initiative', () {
        getIt<Settings>().noInit.value = false;
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        SetInitCommand('Blinkblade', 25).execute();
        expect(GameMethods.canDraw(), isTrue);
      });
    });

    //todo:
    /*group('isInactiveForRule', () {
      test('should return true if monster is inactive by rule', () {
      SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        // In scenario 1, the Guard is inactive in round 1
        expect(GameMethods.isInactiveForRule('Guard'), isTrue);
      });

      test('should return false if monster is not inactive by rule', () {
      SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        expect(GameMethods.isInactiveForRule('Guard'), isFalse);
      });
    });*/

    //todo:
    /*group('getDeck', () {
      test('should return the correct deck', () {
      SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final deck = GameMethods.getDeck('Guard');
        expect(deck, isNotNull);
        expect(deck!.name, 'Guard');
      });

      test('should return null if deck does not exist', () {
      SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final deck = GameMethods.getDeck('NonExistentDeck');
        expect(deck, isNull);
      });
    });*/

    group('getInitiative', () {
      test('should return character initiative', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        SetInitCommand('Blinkblade', 35).execute();
        final character = getIt<GameState>().currentList.first as Character;
        expect(GameMethods.getInitiative(character), 35);
      });

      //todo
      /*test('should return monster initiative', () {
        //getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        AddMonsterCommand().execute();
        DrawAbilityCardCommand().execute();
        final monster = getIt<GameState>()
            .currentList
            .firstWhere((m) => m is Monster) as Monster;
        expect(GameMethods.getInitiative(monster), isNot(99));
        expect(GameMethods.getInitiative(monster), isNot(0));
      });*/
    });

    group('getCharacterByName', () {
      test('should return the correct character', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        final character = GameMethods.getCharacterByName('Blinkblade');
        expect(character, isNotNull);
        expect(character!.id, 'Blinkblade');
      });

      test('should return null if character does not exist', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        final character =
            GameMethods.getCharacterByName('NonExistentCharacter');
        expect(character, isNull);
      });
    });

    group('getCurrentCharacters', () {
      test('should return a list of current characters', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        AddCharacterCommand('Banner Spear', 'Frosthaven', "", 1).execute();
        final characters = GameMethods.getCurrentCharacters();
        expect(characters.length, 2);
        expect(characters[1].id, 'Blinkblade');
        expect(characters[0].id, 'Banner Spear');
      });

      test('should return an empty list if no characters', () {
        getIt<GameState>().clearList();
        final characters = GameMethods.getCurrentCharacters();
        expect(characters, isEmpty);
      });
    });

    group('getCurrentCharacter', () {
      test('should return the character whose turn it is', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Banner Spear', 'Frosthaven', "", 1).execute();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        DrawCommand().execute();
        TurnDoneCommand('Blinkblade').execute(); // It's now Banner Spear's turn
        final character = GameMethods.getCurrentCharacter();
        expect(character, isNotNull);
        expect(character!.id, 'Banner Spear');
      });

      test('should return null if it is not a character turn', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false)
            .execute(); // Adds monsters
        TurnDoneCommand(getIt<GameState>().currentList.first.id)
            .execute(); // It's now a monster's turn
        final character = GameMethods.getCurrentCharacter();
        expect(character, isNull);
      });
    });

    group('getModifierDeck', () {
      test('should return the monster modifier deck', () {
        final deck = GameMethods.getModifierDeck('', getIt<GameState>());
        expect(deck, equals(getIt<GameState>().modifierDeck));
      });

      test('should return the allies modifier deck', () {
        final deck = GameMethods.getModifierDeck('allies', getIt<GameState>());
        expect(deck, equals(getIt<GameState>().modifierDeckAllies));
      });

      test('should return a character modifier deck', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        final deck =
            GameMethods.getModifierDeck('Blinkblade', getIt<GameState>());
        final character = getIt<GameState>().currentList.first as Character;
        expect(deck, equals(character.characterState.modifierDeck));
      });
    });

    group('canAddPerk', () {
      test('should return true if perk can be added', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        final character = getIt<GameState>().currentList.first as Character;
        expect(GameMethods.canAddPerk(character, 0), isTrue);
      });

      test('should return false if perk cannot be added', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        final character = getIt<GameState>().currentList.first as Character;
        AddPerkCommand(character.id, 0).execute();
        expect(GameMethods.canAddPerk(character, 0), isFalse);
      });
    });

    group('canRemovePerk', () {
      test('should return true if perk can be removed', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        final character = getIt<GameState>().currentList.first as Character;
        AddPerkCommand(character.id, 0).execute();
        expect(GameMethods.canRemovePerk(character, 0), isTrue);
      });

      test('should return false if perk cannot be removed', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', 'Blinkblade', 1)
            .execute();
        final character = getIt<GameState>().currentList.first as Character;
        AddPerkCommand(character.id, 12).execute();
        AddPerkCommand(character.id, 13).execute();
        expect(GameMethods.canRemovePerk(character, 5), isFalse);
      });
    });

    group('perkGfxIdToCardId', () {
      test('should return the original gfx id if it is not a perk', () {
        final id = GameMethods.perkGfxIdToCardId(
            'test', PerkModel("", const [], const []), 0);
        expect(id, 'test');
      });

      test('should return the correct card id for a perk', () {
        final perk = PerkModel("", const [], const ['perks/test']);
        final id = GameMethods.perkGfxIdToCardId('perks/test', perk, 0);
        expect(id, 'P0');
      });

      test('should return the correct card id for a perk with two images', () {
        final perk =
            PerkModel("", const [], const ['perks/test', 'perks/test2']);
        final id = GameMethods.perkGfxIdToCardId('perks/test2', perk, 0);
        expect(id, 'P0-2');
      });
    });

    group('getCurrentCharacterAmount', () {
      test('should return the number of characters', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        AddCharacterCommand('Banner Spear', 'Frosthaven', "", 1).execute();
        expect(GameMethods.getCurrentCharacterAmount(), 2);
      });

      test('should return 0 if no characters', () {
        getIt<GameState>().clearList();
        expect(GameMethods.getCurrentCharacterAmount(), 0);
      });
    });

    group('getCurrentMonsters', () {
      test('should return a list of current monsters', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final monsters = GameMethods.getCurrentMonsters();
        expect(monsters.length, 3);
        expect(monsters[0].id, 'Zealot');
        expect(monsters[1].id, 'Chaos Demon');
        expect(monsters[2].id, 'Blood Tumor');
      });

      test('should return an empty list if no monsters', () {
        getIt<GameState>().clearList();
        final monsters = GameMethods.getCurrentMonsters();
        expect(monsters, isEmpty);
      });
    });

    /*group('getNextAvailableBnBStandee', () {
      test('should return the next available standee number', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Buttons and Bugs').execute();
        //todo:
        //SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        AddStandeeCommand(1, null, monster.id, MonsterType.normal, false)
            .execute();
        final nextStandee = GameMethods.getNextAvailableBnBStandee(monster);
        expect(nextStandee, 2);
      });
    });*/

    group('getRandomStandee', () {
      test('should return a valid standee number', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        final standee = GameMethods.getRandomStandee(monster);
        expect(standee, isNot(0));
        expect(standee, lessThanOrEqualTo(monster.type.count));
      });
    });

    group('getFigure', () {
      test('should return a character', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        final figure = GameMethods.getFigure(null, 'Blinkblade');
        expect(figure, isNotNull);
        expect(figure, isA<CharacterState>());
      });

      test('should return a monster instance', () {
        getIt<GameState>().clearList();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        AddStandeeCommand(1, null, monster.id, MonsterType.normal, false)
            .execute();
        final figure = GameMethods.getFigure(
            monster.id, monster.monsterInstances.first.getId());
        expect(figure, isNotNull);
        expect(figure, isA<MonsterInstance>());
      });
    });

    group('getFigureIdFromNr', () {
      test('should return the figure id', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        AddStandeeCommand(1, null, monster.id, MonsterType.normal, false)
            .execute();
        final id = GameMethods.getFigureIdFromNr(monster.id, 1);
        expect(id, isNotNull);
        expect(id, isNotEmpty);
      });
    });

    group('isObjectiveOrEscort', () {
      test('should return true for Objective', () {
        final characterClass =
            AddCharacterCommand("Objective", "na", "whatever", 1);
        expect(
            GameMethods.isObjectiveOrEscort(
                characterClass.character.characterClass),
            isTrue);
      });

      test('should return true for Escort', () {
        final characterClass =
            AddCharacterCommand("Escort", "na", "whatever", 1);
        expect(
            GameMethods.isObjectiveOrEscort(
                characterClass.character.characterClass),
            isTrue);
      });

      test('should return false for other characters', () {
        final characterClass =
            AddCharacterCommand("Blinkblade", "Frosthaven", "whatever", 1);
        expect(
            GameMethods.isObjectiveOrEscort(
                characterClass.character.characterClass),
            isFalse);
      });
    });

    group('shouldShowAlliesDeck', () {
      test('should return true if showAllyDeck setting is true', () {
        getIt<Settings>().showAmdDeck.value = true;
        ShowAllyDeckCommand().execute();
        expect(GameMethods.shouldShowAlliesDeck(), isTrue);
      });

      test('should return false if showAmdDeck setting is false', () {
        getIt<Settings>().showAmdDeck.value = false;
        expect(GameMethods.shouldShowAlliesDeck(), isFalse);
      });

      test('should return true if an ally monster is in play', () {
        getIt<Settings>().showAmdDeck.value = true;
        getIt<GameState>().clearList();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false)
            .execute(); // Adds monsters
        AddMonsterCommand("Zealot", 1, true).execute();
        expect(GameMethods.shouldShowAlliesDeck(), isTrue);
      });
    });

    group('canExpire', () {
      test('should return true for conditions that expire', () {
        expect(GameMethods.canExpire(Condition.strengthen), isTrue);
        expect(GameMethods.canExpire(Condition.muddle), isTrue);
        expect(GameMethods.canExpire(Condition.invisible), isTrue);
        expect(GameMethods.canExpire(Condition.stun), isTrue);
        expect(GameMethods.canExpire(Condition.disarm), isTrue);
        expect(GameMethods.canExpire(Condition.immobilize), isTrue);
        expect(GameMethods.canExpire(Condition.impair), isTrue);
        expect(GameMethods.canExpire(Condition.chill), isTrue);
      });

      test('should return false for conditions that do not expire', () {
        expect(GameMethods.canExpire(Condition.bane), isFalse);
        expect(GameMethods.canExpire(Condition.poison), isFalse);
        expect(GameMethods.canExpire(Condition.wound), isFalse);
        expect(GameMethods.canExpire(Condition.regenerate), isFalse);
        expect(GameMethods.canExpire(Condition.ward), isFalse);
        expect(GameMethods.canExpire(Condition.brittle), isFalse);
      });
    });

    group('isFrosthavenStyledEdition', () {
      test('should return true for Frosthaven', () {
        expect(GameMethods.isFrosthavenStyledEdition('Frosthaven'), isTrue);
      });

      test('should return true for Buttons and Bugs', () {
        expect(
            GameMethods.isFrosthavenStyledEdition('Buttons and Bugs'), isTrue);
      });

      test('should return true for Gloomhaven 2nd Edition', () {
        expect(GameMethods.isFrosthavenStyledEdition('Gloomhaven 2nd Edition'),
            isTrue);
      });

      test('should return true for Mercenary Packs', () {
        expect(
            GameMethods.isFrosthavenStyledEdition('Mercenary Packs'), isTrue);
      });

      test('should return false for Gloomhaven', () {
        expect(GameMethods.isFrosthavenStyledEdition('Gloomhaven'), isFalse);
      });
    });

    group('isFrosthavenStyle', () {
      test('should return true for Frosthaven monster', () {
        final monster = Monster('Ancient Artillery (FH)', 1, false);
        expect(GameMethods.isFrosthavenStyle(monster.type), isTrue);
      });

      test('should return false for Gloomhaven monster', () {
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false)
            .execute(); // Adds monsters
        final monster = Monster('Zealot', 1, false);
        getIt<Settings>().style.value = Style.original;
        expect(GameMethods.isFrosthavenStyle(monster.type), isFalse);
      });

      test('should return true if style is set to Frosthaven', () {
        getIt<Settings>().style.value = Style.frosthaven;
        expect(GameMethods.isFrosthavenStyle(null), isTrue);
      });
    });

    group('isCustomCampaign', () {
      test('should return true for Crimson Scales', () {
        expect(GameMethods.isCustomCampaign('Crimson Scales'), isTrue);
      });

      test('should return true for Trail of Ashes', () {
        expect(GameMethods.isCustomCampaign('Trail of Ashes'), isTrue);
      });

      test('should return true for CCUG', () {
        expect(GameMethods.isCustomCampaign('CCUG'), isTrue);
      });

      test('should return false for Frosthaven', () {
        expect(GameMethods.isCustomCampaign('Frosthaven'), isFalse);
      });
    });

    group('findNrFromScenarioName', () {
      test('should return the scenario number from the name', () {
        expect(GameMethods.findNrFromScenarioName('#1 '), 1);
        expect(
            GameMethods.findNrFromScenarioName('#10.0 A Sticky Situation'), 10);
        expect(GameMethods.findNrFromScenarioName('#123 - Some Scenario'), 123);
      });

      test('should return null if no number is found', () {
        expect(GameMethods.findNrFromScenarioName('Some Scenario'), isNull);
      });
    });

    group('isOgGloomEdition', () {
      test('should return true for Gloomhaven', () {
        SetCampaignCommand('Gloomhaven').execute();
        expect(GameMethods.isOgGloomEdition(), isTrue);
      });

      test('should return false for Frosthaven', () {
        SetCampaignCommand('Frosthaven').execute();
        expect(GameMethods.isOgGloomEdition(), isFalse);
      });
    });

    group('hasLootDeck', () {
      test('should return true if loot deck has cards', () {
        getIt<GameState>().clearList();
        SetCampaignCommand('Frosthaven').execute();
        SetScenarioCommand('#0 Howling in the Snow', false).execute();
        //DrawLootCardCommand().execute();
        expect(GameMethods.hasLootDeck(), isTrue);
      });

      test('should return false if loot deck is empty', () {
        //getIt<GameState>().clearLootDeck();
        SetCampaignCommand('Jaws of the Lion').execute();
        SetScenarioCommand('#5 A Deeper Understanding', false).execute();
        expect(GameMethods.hasLootDeck(), isFalse);
      });

      test('should return false if hideLootDeck setting is true', () {
        getIt<Settings>().hideLootDeck.value = true;
        expect(GameMethods.hasLootDeck(), isFalse);
      });
    });

    group('getFactionCards', () {
      test('should return the correct cards for Demons', () {
        final cards = GameMethods.getFactionCards('Demons');
        expect(cards.length, 4);
        expect(cards[0].gfx, 'Demons-perks/plus1any');
      });

      test('should return the correct cards for Merchant-Guild', () {
        final cards = GameMethods.getFactionCards('Merchant-Guild');
        expect(cards.length, 4);
        expect(cards[0].gfx, 'Merchant-Guild-perks/plus1curse');
      });

      test('should return the correct cards for Military', () {
        final cards = GameMethods.getFactionCards('Military');
        expect(cards.length, 4);
        expect(cards[0].gfx, 'Military-perks/plus1strengthenally');
      });
    });

    group('isCardInAnyCharacterDeck', () {
      test('should return true if card is in a character deck', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        final character = getIt<GameState>().currentList.first as Character;
        AddPerkCommand(character.id, 3).execute(); // Adds a +1 card
        expect(GameMethods.isCardInAnyCharacterDeck('P3'), isTrue);
      });

      test('should return false if card is not in any character deck', () {
        getIt<GameState>().clearList();
        AddCharacterCommand('Blinkblade', 'Frosthaven', "", 1).execute();
        expect(GameMethods.isCardInAnyCharacterDeck('P3'), isFalse);
      });
    });

    group('hasRetaliate', () {
      test('should return true if monster has retaliate', () {
        getIt<GameState>().clearList();
        AddMonsterCommand("Flame Demon (BnB)", 3, false)
            .execute(); // Monster without shield
        AddStandeeCommand(1, null, "Flame Demon (BnB)", MonsterType.boss, false)
            .execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        final instance = monster.monsterInstances.first;
        expect(GameMethods.hasRetaliate(monster, instance), isTrue);
      });

      test('should return false if monster does not have retaliate', () {
        getIt<GameState>().clearList();
        AddMonsterCommand("Black Sludge", 3, false)
            .execute(); // Monster without shield
        AddStandeeCommand(1, null, "Black Sludge", MonsterType.normal, false)
            .execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        final instance = monster.monsterInstances.first;
        expect(GameMethods.hasRetaliate(monster, instance), isFalse);
      });
    });

    group('hasShield', () {
      test('should return true if monster has shield', () {
        getIt<GameState>().clearList();
        AddMonsterCommand("Black Sludge", 3, false)
            .execute(); // Monster without shield
        AddStandeeCommand(1, null, "Black Sludge", MonsterType.normal, false)
            .execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        final instance = monster.monsterInstances.first;
        expect(GameMethods.hasShield(monster, instance), isTrue);
      });

      test('should return false if monster does not have shield', () {
        getIt<GameState>().clearList();
        AddMonsterCommand("Zealot", 1, false)
            .execute(); // Monster without shield
        AddStandeeCommand(1, null, "Zealot", MonsterType.normal, false)
            .execute();
        final monster = getIt<GameState>().currentList.first as Monster;
        final instance = monster.monsterInstances.first;
        expect(GameMethods.hasShield(monster, instance), isFalse);
      });
    });
  });
}
