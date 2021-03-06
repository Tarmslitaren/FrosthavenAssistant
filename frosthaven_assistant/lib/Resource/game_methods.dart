import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/character_class.dart';
import '../Model/monster.dart';
import 'commands/add_standee_command.dart';
import 'enums.dart';
import 'monster_ability_state.dart';

GameState _gameState = getIt<GameState>();

class GameMethods {
  static void updateElements() {
    for (var key in _gameState.elementState.value.keys) {
      if (_gameState.elementState.value[key] == ElementState.full) {
        _gameState.elementState.value[key] = ElementState.half;
      } else if (_gameState.elementState.value[key] == ElementState.half) {
        _gameState.elementState.value[key] = ElementState.inert;
      }
    }
  }

  static int getTrapValue() {
    return 2 + _gameState.level.value;
  }

  static int getHazardValue() {
    return 1 + (_gameState.level.value / 3.0).ceil();
  }

  static int getXPValue() {
    return 4 + 2 * _gameState.level.value;
  }

  static int getCoinValue() {
    if (_gameState.level.value == 7) {
      return 6;
    }
    return 2 + (_gameState.level.value / 2.0).floor();
  }

  static int getRecommendedLevel() {
    double totalLevels = 0;
    double nrOfCharaters = 0;
    for (var item in _gameState.currentList) {
      if (item is Character) {
        totalLevels += item.characterState.level.value;
        nrOfCharaters++;
      }
    }
    if (nrOfCharaters == 0) {
      return 1;
    }
    if (_gameState.solo.value == true) {
      //Take the average level of all characters in the
      // scenario, then add 1 before dividing by 2 and rounding
      // up.
      return ((totalLevels / nrOfCharaters + 1.0) / 2.0).ceil();
    }
    //scenario level is equal to
    //the average level of the characters divided by 2
    //(rounded up)
    return (totalLevels / nrOfCharaters / 2.0).ceil();
  }

  static void addAbilityDeck(Monster monster) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      if (deck.name == monster.type.deck) {
        return;
      }
    }
    _gameState.currentAbilityDecks.add(MonsterAbilityState(monster.type.deck));
  }

  static bool canDraw() {
    for (var item in _gameState.currentList) {
      if (item is Character) {
        if (item.characterState.initiative == 0) {
          if (item.characterState.health.value > 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static void drawAbilityCardFromInactiveDeck() {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.value.isNotEmpty) {
              if (deck.discardPile.isEmpty) {
                deck.draw();
                break;
              }
            }
          }
        }
      }
    }
  }

  static void drawAbilityCards() {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if (item is Monster) {
          if (item.type.deck == deck.name) {
            if (item.monsterInstances.value.isNotEmpty) {
              deck.draw();
              //only draw once from each deck
              break;
            }
          }
        }
      }
    }
  }

  static void unDrawAbilityCards() {
//TODO: implement
  }

  static MonsterAbilityState? getDeck(String name) {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      if (deck.name == name) {
        return deck;
      }
    }
  }

  static void sortCharactersFirst() {
    //late List<ListItemData> newList = List.from(_gameState.currentList);
    _gameState.currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }

      bool aIsChar = false;
      bool bIsChar = false;
      if (a is Character) {
        aIsChar = true;
      }
      if (b is Character) {
        bIsChar = true;
      }
      if (aIsChar && bIsChar) {
        return 0;
      }
      if (bIsChar) {
        return 1;
      }

      //inactive at bottom
      if (a is Monster) {
        if (b is Monster) {
          if (b.monsterInstances.value.isEmpty) {
            return -1;
          }
        }
        if (a.monsterInstances.value.isEmpty) {
          return 1;
        }
      }
      if (b is Monster) {
        if (b.monsterInstances.value.isEmpty) {
          return -1;
        }
        if (a is Monster) {
          if (a.monsterInstances.value.isEmpty) {
            return 1;
          }
        }
      }

      return -1;
    });
    //_gameState.currentList = newList;
  }

  static void sortByInitiative() {
    _gameState.currentList.sort((a, b) {
      //dead characters dead last
      if (a is Character) {
        if (b is Character) {
          if (b.characterState.health.value == 0) {
            return -1;
          }
        }
        if (a.characterState.health.value == 0) {
          return 1;
        }
      }
      if (b is Character) {
        if (b.characterState.health.value == 0) {
          return -1;
        }
        if (a is Character) {
          if (a.characterState.health.value == 0) {
            return 1;
          }
        }
      }
      int aInitiative = 0;
      int bInitiative = 0;
      if (a is Character) {
        aInitiative = a.characterState.initiative;
      } else if (a is Monster) {
        if (a.monsterInstances.value.isEmpty) {
          if (b is Monster && b.monsterInstances.value.isEmpty) {
            return -1;
          }
          return 1; //inactive at bottom
        }

        //find the deck
        for (var item in _gameState.currentAbilityDecks) {
          if (item.name == a.type.deck) {
            aInitiative = item.discardPile.peek.initiative;
          }
        }
      }
      if (b is Character) {
        bInitiative = b.characterState.initiative;
      } else if (b is Monster) {
        if (b.monsterInstances.value.isEmpty) {
          if (a is Monster && a.monsterInstances.value.isEmpty) {
            return 1;
          }
          return -1; //inactive at bottom
        }
        //find the deck
        for (var item in _gameState.currentAbilityDecks) {
          if (item.name == b.type.deck) {
            bInitiative = item.discardPile.peek.initiative;
          }
        }
      }
      return aInitiative.compareTo(bInitiative);
    });
  }

  static void sortMonsterInstances(List<MonsterInstance> instances) {
    instances.sort((a, b) {
      if (a.type == MonsterType.elite && b.type != MonsterType.elite) {
        return -1;
      }
      if (b.type == MonsterType.elite && a.type != MonsterType.elite) {
        return 1;
      }
      return a.standeeNr.compareTo(b.standeeNr);
    });
  }

  static List<Character> getCurrentCharacters() {
    List<Character> characters = [];
    for (ListItemData data in _gameState.currentList) {
      if (data is Character) {
        characters.add(data);
      }
    }
    return characters;
  }

  static int getCurrentCharacterAmount() {
    int res = 0;
    List<Character> characters = [];
    for (ListItemData data in _gameState.currentList) {
      if (data is Character){
        if (data.characterClass.name != "Escort" && data.characterClass.name != "Objective") {
          res++;
        }
      }
    }
    return res;
  }

  static List<Monster> getCurrentMonsters() {
    List<Monster> monsters = [];
    for (ListItemData data in _gameState.currentList) {
      if (data is Monster) {
        monsters.add(data);
      }
    }
    return monsters;
  }

  static void setRoundState(RoundState state) {
    _gameState.roundState.value = state;
  }

  static void shuffleDecksIfNeeded() {
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle) {
        deck.shuffle();
      }
    }
  }

  static void shuffleDecks() {
    for (var deck in _gameState.currentAbilityDecks) {
      deck.shuffle();
    }
  }

  static void addStandee(int? nr, Monster data, MonsterType type) {
    if (nr != null) {
      _gameState.action(AddStandeeCommand(nr, null, data.id, type));
    } else {
      //add first un added nr
      for (int i = 1; i <= data.type.count; i++) {
        bool added = false;
        for (var item in data.monsterInstances.value) {
          if (item.standeeNr == i) {
            added = true;
            break;
          }
        }
        if (!added) {
          _gameState.action(AddStandeeCommand(i, null, data.id, type));
          return;
        }
      }
    }
  }


  static Figure? getFigure(String ownerId, String figureId) {
    for(var item in getIt<GameState>().currentList) {
      if(item.id == figureId) {
        return (item as Character).characterState;
      }
      if(item.id == ownerId){
        if(item is Monster) {

          for (var instance in item.monsterInstances.value) {
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
            if(id == figureId){
              return instance;
            }
          }
        }else if(item is Character){
          for (var instance in item.characterState.summonList.value){
            String id = instance.name + instance.gfx + instance.standeeNr.toString();
            if (id == figureId) {
              return instance;
            }
          }
        }
      }
    }
    return null;
  }

  static Character? createCharacter(String name, String? display, int level) {

    Character? character;
    List<CharacterClass> characters = [];
    for (String key in _gameState.modelData.value.keys){
      characters.addAll(
          _gameState.modelData.value[key]!.characters
      );
    }
    for (CharacterClass characterClass in characters) {
      if (characterClass.name == name) {
        var characterState = CharacterState();
        characterState.level.value = level;

        if (name == "Escort" || name == "Objective") {
          //characterState.initiative = 99;
        }else {
          characterState.health.value = characterClass.healthByLevel[level - 1];
          characterState.maxHealth.value = characterState.health.value;
        }
        characterState.display = name;
        if (display != null) {
          characterState.display = display;
        }
        character = Character(characterState, characterClass);

        if(name == "Beast Tyrant") {
          //create the bear summon
          final int bearHp = 8 + characterState.level.value * 2;

          MonsterInstance bear = MonsterInstance.summon(
              0, MonsterType.summon, "Bear", bearHp, 3, 2, 0, "beast");

          character.characterState.summonList.value.add(bear);
        }

        break;
      }
    }
    return character;
  }

  static Monster? createMonster(String name, int? level, String? healthAdjust) {
    Map<String, MonsterModel> monsters = {};
    for (String key in _gameState.modelData.value.keys) {
      monsters.addAll(_gameState.modelData.value[key]!.monsters);
    }
    level ??= getIt<GameState>().level.value;
    Monster monster = Monster(name, level);
    if (healthAdjust != null) {

      //create new type on the fly
      List<MonsterLevelModel> levels = monster.type.levels;
      List<MonsterLevelModel> newLevels = [];
      for (var level in levels) {
        //Imma gonna assume only elite monsters need this kind of special.
        //Since that seems to be the case so far.
        //find H and replace
        String thisLevelHPAdjust = healthAdjust;
        for(int i = 0; i < thisLevelHPAdjust.length; i++) {
          if (thisLevelHPAdjust[i] == 'H'){
            thisLevelHPAdjust = thisLevelHPAdjust.replaceRange(i, i+1, level.elite!.health.toString());
          }
        }
        //TODO: what happens on refresh!?!? will this go away? TODO again: F this: can make a specila monster in data for this case as well.
        MonsterStatsModel elite = MonsterStatsModel(
            //need to calc H now
            thisLevelHPAdjust,
            level.elite!.move,
            level.elite!.attack,
            level.elite!.range,
            level.elite!.attributes,
            level.elite!.immunities,
            level.elite!.special1,
            level.elite!.special2);
        MonsterLevelModel newLevel = MonsterLevelModel(
            level.level,
            level.normal,
            elite,
            level.boss);
        newLevels.add(newLevel);
      }

      MonsterModel newModdel = MonsterModel(
          monster.type.name,
          monster.type.display,
          monster.type.gfx,
          monster.type.hidden,
          monster.type.flying,
          monster.type.deck,
          monster.type.count,
          newLevels,
          monster.type.edition
      );
      monster.type = newModdel;
    }
    return monster;
  }
}
