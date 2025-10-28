import 'dart:math';

import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../Model/character_class.dart';
import '../Model/monster.dart';
import '../services/service_locator.dart';
import 'enums.dart';

class GameMethods {
  static int getTrapValue() {
    final GameState gameState = getIt<GameState>();
    return 2 + gameState.level.value;
  }

  static int getHazardValue() {
    if (isOgGloomEdition() &&
        !getIt<Settings>().fhHazTerrainCalcInOGGloom.value) {
      return (getTrapValue() / 2).floor();
    }

    final GameState gameState = getIt<GameState>();
    return 1 + (gameState.level.value / 3.0).ceil();
  }

  static int getXPValue() {
    final GameState gameState = getIt<GameState>();
    return 4 + 2 * gameState.level.value;
  }

  static int getCoinValue() {
    final GameState gameState = getIt<GameState>();
    int level = gameState.level.value;
    if (level == 7) {
      return 6;
    }

    return 2 + (level / 2.0).floor();
  }

  static int getRecommendedLevel() {
    double totalLevels = 0;
    double nrOfCharacters = 0;
    final GameState gameState = getIt<GameState>();
    for (var item in gameState.currentList) {
      if (item is Character &&
          !GameMethods.isObjectiveOrEscort(item.characterClass)) {
        totalLevels += item.characterState.level.value;
        nrOfCharacters++;
      }
    }
    if (nrOfCharacters == 0) {
      return 1;
    }
    if (gameState.solo.value) {
      //Take the average level of all characters in the
      // scenario, then add 1 before dividing by 2 and rounding
      // up.
      return ((totalLevels / nrOfCharacters + 1.0) / 2.0).ceil();
    }
    //scenario level is equal to
    //the average level of the characters divided by 2
    //(rounded up)

    return (totalLevels / nrOfCharacters / 2.0).ceil();
  }

  static bool canDraw() {
    final GameState gameState = getIt<GameState>();
    if (gameState.currentList.isEmpty) {
      return false;
    }
    if (getIt<Settings>().noInit.value) {
      return true;
    }
    for (var item in gameState.currentList) {
      if (item is Character) {
        if (item.characterState.initiative.value == 0) {
          if (item.characterState.health.value > 0) {
            return false;
          }
        }
      }
    }

    return true;
  }

  static bool isInactiveForRule(String monsterId) {
    final GameState gameState = getIt<GameState>();
    final rule = gameState.scenarioSpecialRules.firstWhereOrNull(
        (rule) => rule.type == "InactiveMonster" && rule.name == monsterId);
    if (rule != null && rule.list.contains(gameState.round.value)) {
      return true;
    }
    return false;
  }

  static MonsterAbilityState? getDeck(String name) {
    final GameState gameState = getIt<GameState>();
    for (MonsterAbilityState deck in gameState.currentAbilityDecks) {
      if (deck.name == name) {
        return deck;
      }
    }

    return null;
  }

  static int getInitiative(ListItemData item) {
    if (item is Character) {
      return item.characterState.initiative.value;
    } else if (item is Monster) {
      if (!item.isActive) {
        return 99; //sorted last
      }
      final GameState gameState = getIt<GameState>();
      for (var deck in gameState.currentAbilityDecks) {
        if (deck.name == item.type.deck) {
          if (deck.discardPile.isNotEmpty) {
            return deck.discardPile.peek.initiative;
          }
        }
      }
    }
    return 0;
  }

  static Character? getCharacterByName(String name) {
    final GameState gameState = getIt<GameState>();
    for (ListItemData data in gameState.currentList) {
      if (data is Character) {
        if (data.id == name) {
          return data;
        }
      }
    }
    return null;
  }

  static List<Character> getCurrentCharacters() {
    final GameState gameState = getIt<GameState>();
    return getCurrentCharactersForState(gameState);
  }

  static List<Character> getCurrentCharactersForState(GameState state) {
    List<Character> characters = [];
    for (ListItemData data in state.currentList) {
      if (data is Character &&
          !GameMethods.isObjectiveOrEscort(data.characterClass)) {
        characters.add(data);
      }
    }

    return characters;
  }

  static Character? getCurrentCharacter() {
    final GameState gameState = getIt<GameState>();
    for (var item in gameState.currentList) {
      if (item.turnState.value == TurnsState.current) {
        if (item is Character) {
          if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
            return item;
          }
        }
      }
    }
    return null;
  }

  static ModifierDeck getModifierDeck(final String id, GameState state) {
    if (id == "allies") {
      return state.modifierDeckAllies;
    }
    if (id.isNotEmpty) {
      final characters = GameMethods.getCurrentCharactersForState(state);
      for (final character in characters) {
        if (character.id == id) {
          return character.characterState.modifierDeck;
        }
      }
    }

    return state.modifierDeck;
  }

  static bool canAddPerk(Character character, int index) {
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];
    for (final item in perk.remove) {
      if (!deck.hasCard(item)) {
        //check for perk cards in the deck with same id

        int otherPerkCardAdded = 0;
        //find missing card from perk list
        for (int i = 0; i < perks.length; i++) {
          //check if other perk added the card previously
          if (character.characterState.perkList[i]) {
            for (final card in perks[i].add) {
              if (card == item) {
                otherPerkCardAdded++;
              }
            }
            //this only for specific perk cards
            if (item.startsWith("perks/")) {
              for (final card in perks[i].remove) {
                if (card == item) {
                  otherPerkCardAdded--;
                }
              }
            }
          }
        }
        return otherPerkCardAdded > 0;
      }
    }
    return true;
  }

  static bool canRemovePerk(Character character, int index) {
    final deck = character.characterState.modifierDeck;
    final perksFH = character.characterClass.perksFH;
    final useFHPerks =
        character.characterState.useFHPerks.value && perksFH.isNotEmpty;
    final perks = useFHPerks ? perksFH : character.characterClass.perks;
    final perk = perks[index];

    for (final item in perk.add) {
      if (item.startsWith("perks/")) {
        String id = "P$index";
        if (perk.add.last != perk.add.first && item == perk.add.last) {
          id += "-2";
        }
        if (deck.hasCard(id)) {
          return true;
        }
      }
      if (!deck.hasCard(item)) {
        return false;
      }
    }
    return true;
  }

  static String perkGfxIdToCardId(String gfx, PerkModel perk, int index) {
    if (gfx.startsWith("perks/")) {
      String id = "P$index";
      final last = perk.add.last;
      if (perk.add.first != last) {
        if (gfx == last) {
          id += "-2";
        }
      }
      return id;
    }
    return gfx;
  }

  static int getCurrentCharacterAmount() {
    int res = 0;
    final GameState gameState = getIt<GameState>();
    for (ListItemData data in gameState.currentList) {
      if (data is Character) {
        if (!GameMethods.isObjectiveOrEscort(data.characterClass)) {
          res++;
        }
      }
    }

    return res;
  }

  static List<Monster> getCurrentMonsters() {
    List<Monster> monsters = [];
    final GameState gameState = getIt<GameState>();
    for (ListItemData data in gameState.currentList) {
      if (data is Monster) {
        monsters.add(data);
      }
    }

    return monsters;
  }

  static int getNextAvailableBnBStandee(Monster data) {
    final GameState gameState = getIt<GameState>();
    int nrOfStandees = data.type.count;
    for (int i = 0; i < nrOfStandees; i++) {
      bool isAvailable = true;
      for (var item in data.monsterInstances) {
        if (item.standeeNr == i + 1) {
          isAvailable = false;
          break;
        }
      }

      if (isAvailable) {
        //check for other monsters with same standees
        for (var item in gameState.currentList) {
          if (item is Monster) {
            if (item.id != data.id) {
              for (var standee in item.monsterInstances) {
                if (standee.standeeNr == i + 1) {
                  isAvailable = false;
                  break;
                }
              }
            }
          }
          if (!isAvailable) {
            break;
          }
        }
      }
      if (isAvailable) {
        return i + 1;
      }
    }
    return 0;
  }

  static int getRandomStandee(Monster data) {
    final GameState gameState = getIt<GameState>();
    int nrOfStandees = data.type.count;
    if (data.type.name == "Polar Bear") {
      nrOfStandees =
          4; //for the special case where there are only 4 standees in first printing
    }
    List<int> available = [];
    for (int i = 0; i < nrOfStandees; i++) {
      bool isAvailable = true;
      for (var item in data.monsterInstances) {
        if (item.standeeNr == i + 1) {
          isAvailable = false;
          break;
        }
      }
      if (isAvailable) {
        //check for special monsters with same standees
        for (var item in gameState.currentList) {
          if (item is Monster) {
            if (item.id != data.id) {
              if (item.type.gfx == data.type.gfx) {
                for (var standee in item.monsterInstances) {
                  if (standee.standeeNr == i + 1) {
                    isAvailable = false;
                    break;
                  }
                }
              }
            }
          }
          if (!isAvailable) {
            break;
          }
        }
      }
      if (isAvailable) {
        available.add(i + 1);
      }
    }

    //in case we run out of standees...
    if (available.isEmpty) {
      return 0;
    }
    return available[Random().nextInt(available.length)];
  }

  static FigureState? getFigure(String? ownerId, String figureId) {
    for (var item in getIt<GameState>().currentList) {
      if (item.id == figureId) {
        return (item as Character).characterState;
      }
      if (item.id == ownerId) {
        if (item is Monster) {
          for (var instance in item.monsterInstances) {
            String id =
                instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        } else if (item is Character) {
          for (var instance in item.characterState.summonList) {
            String id =
                instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        }
      }
    }
    return null;
  }

  static String getFigureIdFromNr(String ownerId, int nr) {
    for (var item in getIt<GameState>().currentList) {
      if (item.id == ownerId) {
        if (item is Monster) {
          for (var instance in item.monsterInstances) {
            if (instance.standeeNr == nr) {
              return instance.name +
                  instance.gfx +
                  instance.standeeNr.toString();
            }
          }
        }
      }
    }
    return "";
  }

  static bool isObjectiveOrEscort(CharacterClass character) {
    return character.id == "Escort" || character.id == "Objective";
  }

  static bool shouldShowAlliesDeck() {
    final GameState gameState = getIt<GameState>();
    if (!getIt<Settings>().showAmdDeck.value) {
      return false;
    }
    if (gameState.showAllyDeck.value) {
      return true;
    }
    if (!gameState.allyDeckInOGGloom.value && isOgGloomEdition()) {
      return false;
    }
    for (var item in gameState.currentList) {
      if (item is Monster) {
        if (item.isAlly) {
          return true;
        }
      }
    }
    return false;
  }

  static bool canExpire(Condition condition) {
    if (
        //don't remove bane because user need to remember to remove 10hp as well
        condition == Condition.strengthen ||
            condition == Condition.stun ||
            condition == Condition.immobilize ||
            condition == Condition.muddle ||
            condition == Condition.invisible ||
            condition == Condition.disarm ||
            condition == Condition.chill ||
            condition == Condition.impair) {
      return true;
    }
    return false;
  }

  static bool isFrosthavenStyledEdition(String edition) {
    final GameState gameState = getIt<GameState>();
    String scenario = gameState.scenario.value;
    if (edition == "Solo") {
      //#37+ are og solo scenarios
      for (int i = 1; i <= 36; i++) {
        if (scenario.contains("${"#$i"} ")) {
          return true;
        }
      }
      return false;
    }
    return edition == "Frosthaven" ||
        edition == "Buttons and Bugs" ||
        edition == "Gloomhaven 2nd Edition" ||
        edition == "Mercenary Packs";
  }

  static bool summonDoesNotDie(String? ownerId, String id) {
    //exempt special summons that should not be removed at 0
    if (ownerId == "Glacial Torrent" && id == "Glacier") {
      return true;
    } else if (ownerId == "D.O.M.E." && id == "Barrier") {
      return true;
    }
    return false;
  }

  static bool isFrosthavenStyle(MonsterModel? monster) {
    //frosthaven monster
    final monsterFrostHavenStyledEdition =
        monster != null && isFrosthavenStyledEdition(monster.edition);
    if (monsterFrostHavenStyledEdition) {
      return true;
    }
    final style = getIt<Settings>().style.value;
    //frosthaven monsters in other campaigns
    if (monster != null) {
      if (style != Style.frosthaven && !monsterFrostHavenStyledEdition) {
        return false;
      }
    }
    //frosthaven style settings
    return style == Style.frosthaven ||
        style == Style.original &&
            isFrosthavenStyledEdition(getIt<GameState>().currentCampaign.value);
  }

  static bool isCustomCampaign(String campaign) {
    if (campaign == "Crimson Scales") {
      return true;
    }
    if (campaign == "Trail of Ashes") {
      return true;
    }
    if (campaign == "CCUG") {
      return true;
    }
    return false;
  }

  static int? findNrFromScenarioName(String scenario) {
    String nr = scenario.substring(1);
    for (int i = 0; i < nr.length; i++) {
      if (nr[i] == ' ' || nr[i] == ".") {
        nr = nr.substring(0, i);
        return int.tryParse(nr);
      }
    }

    return null;
  }

  static bool isOgGloomEdition() {
    final GameState gameState = getIt<GameState>();
    return !isFrosthavenStyledEdition(gameState.currentCampaign.value);
  }

  static bool hasLootDeck() {
    GameState gameState = getIt<GameState>();
    bool hasLootDeck = !getIt<Settings>().hideLootDeck.value;
    if (gameState.lootDeck.discardPile.isEmpty &&
        gameState.lootDeck.drawPile.isEmpty) {
      hasLootDeck = false;
    }
    return hasLootDeck;
  }

  static List<ModifierCard> getFactionCards(String faction) {
    List<ModifierCard> retVal = [];
    if (faction == "Demons") {
      retVal.add(ModifierCard(CardType.add, "Demons-perks/plus1any"));
      retVal
          .add(ModifierCard(CardType.add, "Demons-perks/plus1retaliate1flip"));
      retVal.add(ModifierCard(CardType.add, "Demons-perks/plus0wardallyflip"));
      retVal.add(ModifierCard(CardType.add, "Demons-perks/unique/fuck3"));
    } else if (faction == "Merchant-Guild") {
      retVal.add(ModifierCard(CardType.add, "Merchant-Guild-perks/plus1curse"));
      retVal.add(ModifierCard(CardType.add, "Merchant-Guild-perks/plus1wound"));
      retVal.add(
          ModifierCard(CardType.add, "Merchant-Guild-perks/plus0heal2flip"));
      retVal
          .add(ModifierCard(CardType.add, "Merchant-Guild-perks/unique/fuck2"));
    } else if (faction == "Military") {
      retVal.add(
          ModifierCard(CardType.add, "Military-perks/plus1strengthenally"));
      retVal.add(ModifierCard(CardType.add, "Military-perks/plus1shield1flip"));
      retVal.add(ModifierCard(CardType.add, "Military-perks/plus1push2flip"));
      retVal.add(ModifierCard(CardType.add, "Military-perks/unique/fuck1"));
    }
    return retVal;
  }

  static bool isCardInAnyCharacterDeck(String gfx) {
    final characters = getCurrentCharacters();
    for (var item in characters) {
      if (item.characterState.modifierDeck.hasCard(gfx)) {
        return true;
      }
    }
    return false;
  }

  static bool hasRetaliate(Monster monster, MonsterInstance figure) {
    return _monsterHasConditionOnCards(monster, figure, "%retaliate%");
  }

  static bool hasShield(Monster monster, MonsterInstance figure) {
    return _monsterHasConditionOnCards(monster, figure, "%shield%");
  }

  static bool _monsterHasConditionOnCards(
      Monster monster, MonsterInstance figure, String condition) {
    bool hasCondition = false;
    //check innate value

    final level = monster.type.levels[monster.level.value];
    if (figure.type == MonsterType.normal) {
      hasCondition =
          level.normal?.attributes.indexWhere((i) => i.contains(condition)) !=
              -1;
    } else if (figure.type == MonsterType.elite) {
      hasCondition =
          level.elite?.attributes.indexWhere((i) => i.contains(condition)) !=
              -1;
    } else if (figure.type == MonsterType.boss) {
      hasCondition =
          level.boss?.attributes.indexWhere((i) => i.contains(condition)) != -1;
    }
    //check ability card
    var deck = GameMethods.getDeck(monster.type.deck);
    if (deck != null &&
        deck.discardPile.isNotEmpty &&
        monster.turnState.value != TurnsState.notDone) {
      if (deck.discardPile.peek.lines
              .firstWhereOrNull((item) => item.contains(condition)) !=
          null) {
        return true;
      }
    }
    return hasCondition;
  }
}
