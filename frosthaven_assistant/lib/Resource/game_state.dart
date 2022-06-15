import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/campaign.dart';
import '../Model/character_class.dart';
import 'action_handler.dart';
import 'card_stack.dart';
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

  CharacterState();

  int initiative = 0;
  final xp = ValueNotifier<int>(0);

  @override
  String toString() {
    return '{'
        '"initiative": $initiative, '
        '"health": ${health.value}, '
        '"level": ${level.value}, '
        '"xp": ${xp.value} '
        '}';
  }

  CharacterState.fromJson(Map<String, dynamic> json) {
    initiative = json['initiative'];
    xp.value = json['xp'];
    health.value = json["health"];
    level.value = json["level"];
  }
}

class ListItemData {
  late String id;
  //final double? fixedHeight;
}

class Character extends ListItemData{
  Character(this.characterState, this.characterClass) {
    id = characterClass.name;
  }
  late final CharacterState characterState;
  late final CharacterClass characterClass;
  //late ListItemState state = ListItemState.chooseInitiative;
  void nextRound(){
    characterState.initiative = 0;
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"characterState": ${characterState.toString()}, '
        '"characterClass": "${characterClass.name}" '
        //'"state": ${state.index} '
        '}';
  }

  Character.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    //state = ListItemState.values[json['state']];
    characterState = CharacterState.fromJson(json['characterState']);
    String className = json['characterClass'];
    for (var item in getIt<GameState>().modelData.value!.characters ){
      if (item.name == className){
        characterClass = item;
        break;
      }
    }
  }


}


enum MonsterType {
  normal,
  elite,
  boss,
  //named
}

class MonsterInstance {
  MonsterInstance(this.standeeNr, this.health, this.maxHealth, this.type);
  final int standeeNr;
  final int health;
  final int maxHealth;
  final MonsterType type;
  //list of conditions

//mark expiring conditions

}

enum ListItemState {
  chooseInitiative, //gray
  waitingTurn, //hopeful
  myTurn, //conditions reminder (above in list is gray)
  doneTurn, //gray, expire conditions
}

class Monster extends ListItemData{
  Monster(String name, this.level){
    id = name;
    for(MonsterModel model in getIt<GameState>().modelData.value!.monsters) {
      if(model.name == name) {
        type = model;
      }
    }

    GameMethods.addAbilityDeck(this);
  }
  late final MonsterModel type;
  late List<MonsterInstance> monsterInstances = [];
  //late final ListItemState state = ListItemState.chooseInitiative;
  int level = 0;

  bool hasElites() {
    for (var instance in monsterInstances) {
      if(instance.type == MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  //includes boss
  bool hasNormal() {
    for (var instance in monsterInstances) {
      if(instance.type != MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  void nextRound(){
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"type": "${type.name}", '
        '"monsterInstances": ${monsterInstances.toString()}, '
        //'"state": ${state.index}, '
        '"level": $level '
        '}';
  }

  Monster.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    level = json['level'];
    String modelName = json['type'];
    //state = ListItemState.values[json["state"]];

    for(var item in getIt<GameState>().modelData.value!.monsters) {
      if(item.name == modelName){
        type = item;
        break;
      }
    }
    monsterInstances = []; //TODO: later

  }
}

class GameState extends ActionHandler{

  GameState() {
    init();
  }

  void init(){

    elementState.value[Elements.fire] = ElementState.inert;
    elementState.value[Elements.ice] = ElementState.inert;
    elementState.value[Elements.air] = ElementState.inert;
    elementState.value[Elements.earth] = ElementState.inert;
    elementState.value[Elements.light] = ElementState.inert;
    elementState.value[Elements.dark] = ElementState.inert;

    fetchCampaignData("JotL");
  }


  fetchCampaignData(String campaign) async {
    final String response = await rootBundle.loadString('assets/data/editions/$campaign.json');
    final data = await json.decode(response);
    modelData.value = CampaignModel.fromJson(data);

    /*action(InitListCommand([
      InitListCommand.createCharacter("Hatchet", 1)!,
      InitListCommand.createCharacter("Demolitionist", 4)!,
      createMonster("Zealot", 4)!,
      createMonster("Giant Viper (JotL)", level.value)!,
      createMonster("Rat Monstrosity", level.value)!,
    ]));*/

    load(); //load saved state from file.
  }
  //data
  final modelData = ValueNotifier<CampaignModel?>(null);
  //TODO: load all the data, not just the one campaign. Data is anyway in same(ish) format, as some campaign items are merged (like classes and monsters) and only campaign in map, or list.

  //state
  final round = ValueNotifier<int>(0);
  final roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);

  final level = ValueNotifier<int>(1);
  final solo = ValueNotifier<bool>(false);
  final scenario = ValueNotifier<String>("");

  List<ListItemData> currentList = []; //has both monsters and characters


  List<MonsterAbilityState> currentAbilityDecks = <MonsterAbilityState>[]; //add to here when adding a monster type

  //elements
  final elementState = ValueNotifier< Map<Elements, ElementState> >(HashMap());

  //GameState? savedState; //load from file, save to file on interval/ app in background? or after any operation?

  //config: TODO: move to own state
  final userScaling = ValueNotifier<double>(1.0);
  final showCalculated = ValueNotifier<bool>(true);

  @override
  String toString() {
    Map<String, int> elements = {};
    for( var key in elementState.value.keys) {
      elements[key.index.toString()] = elementState.value[key]!.index;
    }

    print("kuken");
    print(json.encode(elements));
    return '{'
        '"level": ${level.value}, '
        '"solo": ${solo.value}, '
        '"roundState": ${roundState.value.index}, '
        '"round": ${round.value}, '
        '"scenario": "${scenario.value}", '
        '"currentList": ${currentList.toString()}, '
        '"currentAbilityDecks": ${currentAbilityDecks.toString()}, '
        '"elementState": ${json.encode(elements)} ' //didn't like the map?
        '}';
  }

  Future<void> save() async {
    //1 serialize to json
    String value = toString();
    const sharedPrefsKey = 'gameState';
    bool _hasError = false;
    bool _isWaiting = true;
    //notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
        // save
        // uncomment this to simulate an error-during-save
        // if (_value > 3) throw Exception("Artificial Error");
        await prefs.setString(sharedPrefsKey, value);
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    //notifyListeners();
  }

  Future<void> load() async {
    //have to call after init or element state overridden

    const sharedPrefsKey = 'gameState';
    bool _hasError = false;
    bool _isWaiting = true;
    String value = "";
    //notifyListeners();
    // artificial delay so we can see the UI changes
    try {
      final prefs = await SharedPreferences.getInstance();
      value = prefs.getString(sharedPrefsKey) ?? "";
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;

    if (value.isNotEmpty){
      Map<String, dynamic> data = jsonDecode(value);
      level.value = data['level'] as int;
      scenario.value = data['scenario'];// as String;
      round.value = data['round'] as int;
      roundState.value =  RoundState.values[data['roundState']];
      solo.value = data['solo'] as bool; //TODO: does not update properly (because changing it is not a command
      var list = data['currentList'] as List;
      currentList.clear();
      List<ListItemData> newList = [];
      for (Map<String, dynamic> item in list){
        if (item["characterClass"] != null) {
          Character character = Character.fromJson(item);
          //is character
          newList.add(character);
        } else if (item["type"] != null){
          //is monster
          Monster monster = Monster.fromJson(item);
          newList.add(monster);

        }
        //create the objects
        //add to currentList.
      }
      currentList = newList;

      var decks = data['currentAbilityDecks'] as List;
      currentAbilityDecks.clear();
      for (Map<String, dynamic> item in decks){
        MonsterAbilityState state = MonsterAbilityState(item["name"]);

        List<MonsterAbilityCardModel> newDrawList = [];
        List drawPile = item["drawPile"] as List;
        for(var item in drawPile){
          int nr = item["nr"];
          for(var card in state.drawPile.getList()){
            if(card.nr == nr){
              newDrawList.add(card);
            }
          }
        }
        List<MonsterAbilityCardModel> newDiscardList = [];
        for(var item in item["discardPile"] as List){
          int nr = item["nr"];
          for(var card in state.drawPile.getList()){
            if(card.nr == nr){
              newDiscardList.add(card);
            }
          }
        }
        state.drawPile.getList().clear();
        state.discardPile.getList().clear();
        state.drawPile.setList(newDrawList);
        state.discardPile.setList(newDiscardList);


        currentAbilityDecks.add(state);
      }

      Map elementData = data['elementState'];


      elementState.value[Elements.fire] = ElementState.values[elementData[Elements.fire.index.toString()]];
      elementState.value[Elements.ice] = ElementState.values[elementData[Elements.ice.index.toString()]];
      elementState.value[Elements.air] = ElementState.values[elementData[Elements.air.index.toString()]];
      elementState.value[Elements.earth] = ElementState.values[elementData[Elements.earth.index.toString()]];
      elementState.value[Elements.light] = ElementState.values[elementData[Elements.light.index.toString()]];
      elementState.value[Elements.dark] = ElementState.values[elementData[Elements.dark.index.toString()]];

    }
  }

}