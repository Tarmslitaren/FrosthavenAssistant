import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

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
      //TODO: don't draw if there are no monsters of the type
      deck.draw();
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
    late List<ListItemData> newList = List.from(_gameState.currentList);
    newList.sort((a, b) {
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
      return -1;
    }
    );
    _gameState.currentList = newList;
  }

  static void sortByInitiative() {
    //hack:
    late List<ListItemData> newList = List.from(_gameState.currentList);


    newList.sort((a, b) {
      int aInitiative = 0;
      int bInitiative = 0;
      if (a is Character) {
        aInitiative = a.characterState.initiative;
      } else if (a is Monster) {

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
    _gameState.currentList = newList;
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
}