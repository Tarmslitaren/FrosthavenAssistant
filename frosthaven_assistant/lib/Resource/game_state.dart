import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/campaign.dart';
import '../Model/character_class.dart';
import 'action_handler.dart';
import 'commands.dart';
import 'monster_ability_state.dart';

enum ElementState{
  full,
  half,
  inert

}

enum Elements{
  fire,
  ice,
  air,
  earth,
  light,
  dark
}

enum RoundState{
  chooseInitiative,
  playTurns,
}

class FigureState {
  final health = ValueNotifier<int>(0); //TODO: this is no good: instances? or does it work?
  final level = ValueNotifier<int>(1);
  //array of conditions
}

class CharacterState extends FigureState {
  int initiative = 0;
  final xp = ValueNotifier<int>(0);
}

class ListItemData {
  late String id;
  //final double? fixedHeight;
}

class Character extends ListItemData{
  Character(this.characterState, this.characterClass) {
    id = characterClass.name;
  }
  final CharacterState characterState;
  final CharacterClass characterClass;
  final ListItemState state = ListItemState.chooseInitiative;
}

class CardStack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
  void init(List<E> list) {
    _list.addAll(list);
  }
  void shuffle() {
    _list.shuffle(Random());
  }
  void undoShuffle() { //mun djö!
    //TODO: how to undo and redo random stuff? I need to use a set random and somehow turn back time
    //so basically save whole list state for every command and overwrite instead of random shuffle

  }

  int size() {
    return _list.length;
  }
}

enum MonsterType {
  normal,
  elite,
  boss,
  //named
}

class MonsterInstance {
  MonsterInstance(this.standeeNr, this.health, this.maxHealth, this.isElite, this.type);
  final int standeeNr;
  final int health;
  final int maxHealth;
  final bool isElite;
  final MonsterType type;
  //list of conditions

//mark expiring conditions

}

enum ListItemState {
  chooseInitiative, //gray
  waitingTurn, //hopeful
  myTurn, //conditions reminder (above in list is gray)
  doneTurn, //gray, expire conditoins
}

class Monster extends ListItemData{
  Monster(String name, this.level){
    id = name;
    for(MonsterModel model in getIt<GameState>().modelData.value!.monsters) {
      if(model.name == name) {
        type = model;
      }
    }

    getIt<GameState>().addAbilityDeck(this);
  }
  late final MonsterModel type;
  final List<MonsterInstance> monsterInstances = [];
  final ListItemState state = ListItemState.chooseInitiative;
  final int level;
  late final MonsterAbilityState deck; //for ease of reference
}

class GameState extends ActionHandler{

  GameState() {
    fetchCampaignData("JotL");
    //load save state; then call initlist command
    elementState.value[Elements.fire] = ElementState.inert;
    elementState.value[Elements.ice] = ElementState.inert;
    elementState.value[Elements.air] = ElementState.inert;
    elementState.value[Elements.earth] = ElementState.inert;
    elementState.value[Elements.light] = ElementState.inert;
    elementState.value[Elements.dark] = ElementState.inert;

  }
  fetchCampaignData(String campaign) async {
    final String response = await rootBundle.loadString('assets/data/editions/$campaign.json');
    final data = await json.decode(response);
    modelData.value = CampaignModel.fromJson(data);

    action(InitListCommand([
      InitListCommand.createCharacter("Hatchet", 1)!,
      InitListCommand.createCharacter("Demolitionist", 4)!,
      createMonster("Zealot", 4)!,
      createMonster("Giant Viper (JotL)", level.value)!,
      createMonster("Rat Monstrosity", level.value)!,
    ]));
  }
  //data
  final modelData = ValueNotifier<CampaignModel?>(null);
  //TODO: load all the data, not just the one campaign. Data is anyway in same(ish) format, as some campaing items are merged (like classes and monsters) and only campaign in map, or list.

  //state
  final round = ValueNotifier<int>(0);
  final roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);

  void setRoundState(RoundState state) {
    roundState.value = state;
  }

  final level = ValueNotifier<int>(1); //TODO: update and stuff
  final scenario = ValueNotifier<String>("");

  List<ListItemData> currentList = []; //has both monsters and characters
  void sortCharactersFirst(){
    late List<ListItemData> newList = List.from(currentList);
    newList.sort((a, b) {

      bool aIsChar = false;
      bool bIsChar = false;
      if(a is Character) {
        aIsChar = true;
      }
      if(b is Character) {
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
    currentList = newList;
  }
  void sortByInitiative(){

    //hack:
    late List<ListItemData> newList = List.from(currentList);


    newList.sort((a, b) {
      int aInitiative = 0;
      int bInitiative = 0;
      if(a is Character) {
        aInitiative = a.characterState.initiative;
      } else if (a is Monster) {
        aInitiative = a.deck.discardPile.peek.initiative;
      }
      if(b is Character) {
        bInitiative = b.characterState.initiative;
      } else if (b is Monster) {
        bInitiative = b.deck.discardPile.peek.initiative;
      }
      return aInitiative.compareTo(bInitiative);
    }
    );
    currentList = newList;
  }

  List<Character> getCurrentCharacters(){
    List<Character> characters = [];
    for(ListItemData data in currentList) {
      if(data is Character) {
        characters.add(data);
      }
    }
    return characters;
  }

  final currentAbilityDecks = <MonsterAbilityState>[]; //add to here when adding a monster type
  void addAbilityDeck(Monster monster) {
    for (MonsterAbilityState deck in currentAbilityDecks) {
      if(deck.name == monster.type.deck) {
        //add ref to monster (this code smells a bit though.)
        monster.deck = deck;
        return;
      }
    }
    monster.deck = MonsterAbilityState(monster.type.deck);
    currentAbilityDecks.add(monster.deck);
  }

  bool canDraw() {
    for (var item in currentList) {
      if(item is Character) {
        if(item.characterState.initiative == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void drawAbilityCards(){
    for(MonsterAbilityState deck in currentAbilityDecks) {
      //TODO: don't draw if there are no monsters of the type
      if(deck.discardPile.isNotEmpty && deck.discardPile.peek.shuffle){
        deck.shuffle();
      }
      deck.draw();
    }
  }
  void unDrawAbilityCards(){
//TODO: implement
  }

  MonsterAbilityState? getDeck(String name) {
    for (MonsterAbilityState deck in currentAbilityDecks) {
      if (deck.name == name) {
        return deck;
      }
    }
  }

  //elements
  final elementState = ValueNotifier< Map<Elements, ElementState> >(HashMap());
  void updateElements(){
    for (var key in elementState.value.keys) {
      if(elementState.value[key] == ElementState.full) {
        elementState.value[key] = ElementState.half;
      }
      else if(elementState.value[key] == ElementState.half) {
        elementState.value[key] = ElementState.inert;
      }
    }
  }

  GameState? savedState; //load from file, save to file on interval/ app in background? or after any operation?

  //config: TODO: move to own state
  final userScaling = ValueNotifier<double>(1.0);
}