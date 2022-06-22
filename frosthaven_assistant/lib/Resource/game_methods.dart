import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/monster.dart';
import 'commands/add_standee_command.dart';
import 'monster_ability_state.dart';

GameState _gameState = getIt<GameState>();

class GameMethods {


  static void updateElements() {
    for (var key in _gameState.elementState.value.keys) {
      if (_gameState.elementState.value[key] == ElementState.full) {
        _gameState.elementState.value[key] = ElementState.half;
      }
      else if (_gameState.elementState.value[key] == ElementState.half) {
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
          return false;
        }
      }
    }
    return true;
  }

  static void drawAbilityCards() {
    for (MonsterAbilityState deck in _gameState.currentAbilityDecks) {
      for (var item in _gameState.currentList) {
        if(item is Monster) {
          if(item.type.deck == deck.name) {
            if (item.monsterInstances.value.isNotEmpty) {
              deck.draw();
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

      if (a is Monster) {
        if(a.monsterInstances.value.isEmpty) {
          return 1; //inactive at bottom
        }
      }
      if (b is Monster) {
        if(b.monsterInstances.value.isEmpty) {
          return -1; //inactive at bottom
        }
      }
      return -1;
    }
    );
    //_gameState.currentList = newList;
  }

  static void sortByInitiative() {
    //hack:
    //late List<ListItemData> newList = List.from(_gameState.currentList);


    _gameState.currentList.sort((a, b) {
      int aInitiative = 0;
      int bInitiative = 0;
      if (a is Character) {
        aInitiative = a.characterState.initiative;
      } else if (a is Monster) {
        if(a.monsterInstances.value.isEmpty) {
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
        if(b.monsterInstances.value.isEmpty) {
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
    }
    );
    //_gameState.currentList = newList;

  }

  static void sortMonsterInstances(List<MonsterInstance> instances){
    instances.sort((a, b) {
      if(a.type == MonsterType.elite && b.type != MonsterType.elite){
        return -1;
      }
      if(b.type == MonsterType.elite && a.type != MonsterType.elite){
        return 1;
      }
      return a.standeeNr.compareTo(b.standeeNr);
    }
    );
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

  static void shuffleDecksIfNeeded(){
    for(var deck in _gameState.currentAbilityDecks) {
      if (deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle) {
        deck.shuffle();
      }
    }
  }

  static void shuffleDecks(){
    for(var deck in _gameState.currentAbilityDecks) {
      deck.shuffle();
    }
  }

  static void addStandee(int? nr, Monster data, MonsterType type ){
    if(nr != null) {
      _gameState.action(AddStandeeCommand(nr, data, type));
    }
    else {
      //add first un added nr
      for(int i = 1; i <= data.type.count; i++) {
        bool added = false;
        for (var item in data.monsterInstances.value) {
          if (item.standeeNr == i) {
            added = true;
            break;
          }
        }
        if (!added) {
          _gameState.action(AddStandeeCommand(i, data, type));
          return;
        }
      }
    }
  }

  static Monster? createMonster(String name, int level) {
    for (MonsterModel monster in getIt<GameState>().modelData.value!.monsters) {
      if (monster.name == name) {
        Monster monster = Monster(name, level);
        return monster;
      }
    }
    return null;
  }
}