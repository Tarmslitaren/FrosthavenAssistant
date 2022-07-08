import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Model/summon.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/campaign.dart';
import '../Model/character_class.dart';
import 'action_handler.dart';
import 'card_stack.dart';
import 'enums.dart';
import 'monster_ability_state.dart';

class Figure {
  final health = ValueNotifier<int>(0);
  final level = ValueNotifier<int>(1);
  final maxHealth = ValueNotifier<int>(0); //? //needed for the times you wanna set hp yourself, for special reasons
  final conditions = ValueNotifier<List<Condition>>([]);
}

class CharacterState extends Figure{

  CharacterState();

  String display = "";
  int initiative = 0;
  final xp = ValueNotifier<int>(0);
  final chill = ValueNotifier<int>(0);

  final summonList = ValueNotifier<List<MonsterInstance>>([]);


  @override
  String toString() {
    return '{'
        '"initiative": $initiative, '
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"xp": ${xp.value}, '
        '"chill": ${chill.value}, '
        '"display": "$display", '
        '"summonList": ${summonList.value.toString()}, '
        '"conditions": ${conditions.value.toString()} '
        '}';
  }

  CharacterState.fromJson(Map<String, dynamic> json) {
    initiative = json['initiative'];
    xp.value = json['xp'];
    chill.value = json['chill'];
    health.value = json["health"];
    level.value = json["level"];
    maxHealth.value = json["maxHealth"];
    display = json['display'];

    List<dynamic> summons = json["summonsList"];
    for(var item in summons){
      summonList.value.add(MonsterInstance.fromJson(item));
    }

    List<dynamic> condis = json["conditions"];

    for(int item in condis){
      conditions.value.add(Condition.values[item]);
    }
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
    if (id != "Objective" && id != "Escort") {
      characterState.initiative = 0;
    }
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
    GameState gameState = getIt<GameState>();
    List<CharacterClass> characters = [];
    for (String key in gameState.modelData.value.keys){
      characters.addAll(
          gameState.modelData.value[key]!.characters
      );
    }
    for (var item in characters ){
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
  //named?
  summon
}

class MonsterInstance extends Figure{
  MonsterInstance(this.standeeNr, this.type, Monster monster) {
      setLevel(monster);
      gfx = monster.type.gfx;
      name = monster.type.name;
      move = 0; //only used for summons
      attack = 0;
      range = 0;
  }

  MonsterInstance.summon(this.standeeNr, this.type, this.name, int summonHealth, this.move, this.attack, this.range, this.gfx) {
      //deal with summon init
    maxHealth.value = summonHealth;
    health.value = summonHealth;
  }

  late final int standeeNr;
  late final MonsterType type;
  late final String name;
  late final String gfx;

  //summon stats
  late int move;
  late int attack;
  late int range;


  void setLevel(Monster monster) {
    dynamic newHealthValue = 10; //need to put something outer than 0 or the standee will die immediately causing glitch
    if (type == MonsterType.boss) {
      newHealthValue = monster.type.levels[monster.level.value].boss!.health;
    } else if (type == MonsterType.elite) {
      newHealthValue= monster.type.levels[monster.level.value].elite!.health;
    } else if (type == MonsterType.normal) {
      newHealthValue = monster.type.levels[monster.level.value].normal!.health;
    }
    int? value = StatCalculator.calculateFormula(newHealthValue);
    if (value != null) {
      maxHealth.value = value;
    } else {
      //handle edge case
      if(newHealthValue == "Hollowpact"){
        int value = 7;
        for(var item in getIt<GameState>().currentList) {
          if(item is Character && item.id == "Hollowpact") {
            value = item.characterClass.healthByLevel[item.characterState.level.value-1];
            break;
          }
        }
        maxHealth.value = value;
      }

    }
    //maxHealth.value = StatCalculator.calculateFormula(newHealthValue)!;
    level.value = monster.level.value;
    health.value = maxHealth.value;
  }

  @override
  String toString() {
    return '{'
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"standeeNr": $standeeNr, '
        '"move": $move, '
        '"attack": $attack, '
        '"range": $range, '
        '"name": "$name", '
        '"gfx": "$gfx", '
        '"type": ${type.index}, '
        '"conditions": ${conditions.value.toString()} '
        '}';
  }

  MonsterInstance.fromJson(Map<String, dynamic> json) {
    standeeNr = json["standeeNr"];
    health.value = json["health"];
    level.value = json["level"];
    maxHealth.value = json["maxHealth"];
    name = json["name"];
    gfx = json["gfx"];
    type = MonsterType.values[json["type"]];
    move = json["move"];
    attack = json["attack"];
    range = json["range"];
    List<dynamic> condis = json["conditions"];
    for(int item in condis){
      conditions.value.add(Condition.values[item]);
    }
  }

}

class Monster extends ListItemData{
  Monster(String name, int level){
    id = name;
    this.level.value = level;
    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys){
      monsters.addAll(
          gameState.modelData.value[key]!.monsters
      );
    }
    for(String key in monsters.keys) {
      if(key == name) {
        type = monsters[key]!;
      }
    }

    GameMethods.addAbilityDeck(this);
  }
  late final MonsterModel type;
  final monsterInstances = ValueNotifier<List<MonsterInstance>>([]);
  //late final ListItemState state = ListItemState.chooseInitiative;
  final level = ValueNotifier<int>(0);

  bool hasElites() {
    for (var instance in monsterInstances.value) {
      if(instance.type == MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  //includes boss
  bool hasNormal() {
    for (var instance in monsterInstances.value) {
      if(instance.type != MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  void nextRound(){
  }

  void setLevel(int level) {
    this.level.value = level;
    for(var item in monsterInstances.value) {
      item.setLevel(this);
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"type": "${type.name}", '
        '"monsterInstances": ${monsterInstances.value.toString()}, '
        //'"state": ${state.index}, '
        '"level": ${level.value} '
        '}';
  }

  Monster.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    level.value = json['level'];
    String modelName = json['type'];
    //state = ListItemState.values[json["state"]];

    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys){
      monsters.addAll(
          gameState.modelData.value[key]!.monsters
      );
    }
    for(var item in monsters.keys) {
      if(item == modelName){
        type = monsters[item]!;
        break;
      }
    }

    List<dynamic> instanceList = json["monsterInstances"];

    List<MonsterInstance> newList = [];
    for(Map<String, dynamic> item in instanceList){
      var instance = MonsterInstance.fromJson(item);
      newList.add(instance);

    }
    monsterInstances.value = newList;
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

    initGame();
  }

  initGame() async {

    final String response = await rootBundle.loadString('assets/data/summons.json');
    final data = await json.decode(response);

    //load loose summons
    if(data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys){
        itemSummonData.add(SummonModel.fromJson(summons[key], key));
      }
    }

    await fetchCampaignData("na");
    await fetchCampaignData("JotL");
    await fetchCampaignData("Gloomhaven");
    await fetchCampaignData("Forgotten Circles");
    await fetchCampaignData("Crimson Scales");
    await fetchCampaignData("Frosthaven");
    //TODO:specify campaigns in data, or scrub the directory for files

    load(); //load saved state from file.
  }

  fetchCampaignData(String campaign) async {
    final String response = await rootBundle.loadString('assets/data/editions/$campaign.json');
    final data = await json.decode(response);
    modelData.value[campaign] = CampaignModel.fromJson(data);
  }
  //data
  final modelData = ValueNotifier<Map<String, CampaignModel>>({});
  List<SummonModel> itemSummonData = [];

  //state
  final currentCampaign = ValueNotifier<String>("JotL");
  final round = ValueNotifier<int>(0);
  final roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);

  //TODO: ugly hacks to delay list update (doesn't need to be here though)
  final updateList = ValueNotifier<int>(0);
  final killMonsterStandee = ValueNotifier<int>(-1);

  final level = ValueNotifier<int>(1);
  final solo = ValueNotifier<bool>(false);
  final scenario = ValueNotifier<String>("");

  List<ListItemData> currentList = []; //has both monsters and characters


  List<MonsterAbilityState> currentAbilityDecks = <MonsterAbilityState>[]; //add to here when adding a monster type

  //elements
  final elementState = ValueNotifier< Map<Elements, ElementState> >(HashMap());

  //GameState? savedState; //load from file, save to file on interval/ app in background? or after any operation?
  //actually make a list of saved states and use for the undo/redo feature

  //config: TODO: move to own state
  final userScaling = ValueNotifier<double>(1.0);
  final fullScreen = ValueNotifier<bool>(false);
  final showCalculated = ValueNotifier<bool>(true);

  @override
  String toString() {
    Map<String, int> elements = {};
    for( var key in elementState.value.keys) {
      elements[key.index.toString()] = elementState.value[key]!.index;
    }

    return '{'
        '"level": ${level.value}, '
        '"solo": ${solo.value}, '
        '"roundState": ${roundState.value.index}, '
        '"round": ${round.value}, '
        '"scenario": "${scenario.value}", '
        '"currentCampaign": "${currentCampaign.value}", '
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
      currentCampaign.value = data['currentCampaign'];
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