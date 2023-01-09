import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frosthaven_assistant/Model/summon.dart';

import '../../Model/campaign.dart';
import '../../Model/scenario.dart';
import '../action_handler.dart';
import '../enums.dart';
import 'game_save_state.dart';
import 'list_item_data.dart';
import 'loot_deck_state.dart';
import 'modifier_deck_state.dart';
import 'monster_ability_state.dart';

class GameState extends ActionHandler{ //TODO: put action handler in own place

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
    rootBundle.evict('assets/data/summon.json');
    //cache false to make hot restart apply changes to base file. Does not work with hot reload...
    final String response = await rootBundle.loadString('assets/data/summons.json', cache: false);
    final data = await json.decode(response);

    //load loose summons
    if(data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys){
        itemSummonData.add(SummonModel.fromJson(summons[key], key));
      }
    }

    Map<String, CampaignModel> map = {};

    await fetchCampaignData("na", map);
    await fetchCampaignData("JotL", map);
    await fetchCampaignData("Gloomhaven", map);
    await fetchCampaignData("Forgotten Circles", map);
    await fetchCampaignData("Crimson Scales", map);
    await fetchCampaignData("Frosthaven", map);
    await fetchCampaignData("Seeker of Xorn", map);
    await fetchCampaignData("Solo", map);
    //TODO:specify campaigns in data, or scrub the directory for files

    load(); //load saved state from file.

    modelData.value = map;
  }

  fetchCampaignData(String campaign, Map<String, CampaignModel> map) async {
    rootBundle.evict('assets/data/editions/$campaign.json');
    final String response = await rootBundle.loadString('assets/data/editions/$campaign.json', cache: false);
    final data = await json.decode(response);
    map[campaign] = CampaignModel.fromJson(data);
  }

  //data
  final modelData = ValueNotifier<Map<String, CampaignModel>>({});
  List<SummonModel> itemSummonData = [];

  //state
  final currentCampaign = ValueNotifier<String>("JotL");
  final round = ValueNotifier<int>(1);
  final roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);

  //TODO: ugly hacks to delay list update (doesn't need to be here though)
  final updateList = ValueNotifier<int>(0);
  final killMonsterStandee = ValueNotifier<int>(-1);
  final updateForUndo = ValueNotifier<int>(0);

  final level = ValueNotifier<int>(1);
  final solo = ValueNotifier<bool>(false);
  final scenario = ValueNotifier<String>("");
  List<SpecialRule> scenarioSpecialRules = []; //has both monsters and characters
  late LootDeck lootDeck = LootDeck.empty(); //loot deck for current scenario
  final toastMessage = ValueNotifier<String>("");

  List<ListItemData> currentList = []; //has both monsters and characters

  List<MonsterAbilityState> currentAbilityDecks = <MonsterAbilityState>[]; //add to here when adding a monster type

  //elements
  final elementState = ValueNotifier< Map<Elements, ElementState> >(HashMap());

  //modifierDeck
  ModifierDeck modifierDeck = ModifierDeck("");
  ModifierDeck modifierDeckAllies = ModifierDeck("Allies");

  //unlocked characters
  Set<String> unlockedClasses = {};


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
        '"scenarioSpecialRules": ${scenarioSpecialRules.toString()}, '
        '"currentCampaign": "${currentCampaign.value}", '
        '"currentList": ${currentList.toString()}, '
        '"currentAbilityDecks": ${currentAbilityDecks.toString()}, '
        '"modifierDeck": ${modifierDeck.toString()}, '
        '"modifierDeckAllies": ${modifierDeckAllies.toString()}, '
        '"lootDeck": ${lootDeck.toString()}, ' //does this work if null?
        '"unlockedClasses": ${jsonEncode(unlockedClasses.toList())}, '
        '"elementState": ${json.encode(elements)} '
        '}';
  }

  Future<void> save() async {
    GameSaveState state = GameSaveState();
    state.save();
    state.saveToDisk();
    gameSaveStates.add(state); //do this from action handler instead
  }

  Future<void> load() async {
    GameSaveState state = GameSaveState();
    state.loadFromDisk();
    gameSaveStates.add(state); //init state: means game save state is one larger than command list
  }

  Future<void> loadFromData(String data) async {
    GameSaveState state = GameSaveState();
    state.loadFromData(data);
    gameSaveStates.add(state);
    state.saveToDisk();
  }


}