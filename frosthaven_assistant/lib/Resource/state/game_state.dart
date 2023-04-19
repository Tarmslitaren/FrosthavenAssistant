library game_state;
import 'package:built_collection/built_collection.dart';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Model/summon.dart';

import '../../Layout/main_list.dart';
import '../../Model/campaign.dart';
import '../../Model/room.dart';
import '../../Model/scenario.dart';
import '../action_handler.dart';
import '../enums.dart';
import 'list_item_data.dart';
import 'loot_deck_state.dart';
import 'modifier_deck_state.dart';
import 'monster_ability_state.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/MonsterAbility.dart';
import '../../services/service_locator.dart';
import 'character.dart';
import 'monster.dart';

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/state/character_state.dart';
import 'package:frosthaven_assistant/Resource/state/figure_state.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/monster_instance.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import '../../Layout/menus/auto_add_standee_menu.dart';
import '../../Model/character_class.dart';
import '../../Model/monster.dart';
import '../commands/add_standee_command.dart';

part "game_save_state.dart";
part "../game_methods.dart";

class GameState extends ActionHandler {
  //TODO: put action handler in own place

  GameState() {
    init();
  }

  void init() {
    _elementState[Elements.fire] = ElementState.inert;
    _elementState[Elements.ice] = ElementState.inert;
    _elementState[Elements.air] = ElementState.inert;
    _elementState[Elements.earth] = ElementState.inert;
    _elementState[Elements.light] = ElementState.inert;
    _elementState[Elements.dark] = ElementState.inert;

    initGame();
  }

  initGame() async {
    rootBundle.evict('assets/data/summon.json');
    //cache false to make hot restart apply changes to base file. Does not work with hot reload...
    final String response =
        await rootBundle.loadString('assets/data/summons.json', cache: false);
    final data = await json.decode(response);

    //load loose summons
    if (data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys) {
        itemSummonData.add(SummonModel.fromJson(summons[key], key));
      }
    }

    Map<String, CampaignModel> map = {};

    final String editions = await rootBundle
        .loadString('assets/data/editions/editions.json', cache: false);
    final Map<String, dynamic> editionData = await json.decode(editions);
    for (String item in editionData["editions"]) {
      this.editions.add(item);

      List<RoomsModel> roomData = [];
      await fetchRoomData(item).then((value) {
        if (value != null) roomData.addAll(value.roomData);
      });

      await fetchCampaignData(item, map, roomData);
    }

    load(); //load saved state from file.

    modelData.value = map;
  }

  Future<EditionRoomsModel?> fetchRoomData(String campaign) async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/rooms/$campaign.json');
      final data = await json.decode(response);
      return EditionRoomsModel.fromJson(data);
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return null;
    }
  }

  fetchCampaignData(String campaign, Map<String, CampaignModel> map,
      List<RoomsModel> roomsData) async {
    rootBundle.evict('assets/data/editions/$campaign.json');
    final String response = await rootBundle
        .loadString('assets/data/editions/$campaign.json', cache: false);
    final data = await json.decode(response);
    map[campaign] = CampaignModel.fromJson(data, roomsData);
  }

  //data todo: move out of here
  List<String> editions = [];
  final modelData = ValueNotifier<Map<String, CampaignModel>>({});
  List<SummonModel> itemSummonData = [];

  //TODO: ugly hacks to delay list update (doesn't need to be here though)
  final updateList = ValueNotifier<int>(0);
  final killMonsterStandee = ValueNotifier<int>(-1);
  final updateForUndo = ValueNotifier<int>(0);

  //state
  ValueListenable<String> get currentCampaign => _currentCampaign;
  final _currentCampaign = ValueNotifier<String>("Jaws of the Lion");

  ValueListenable<int> get round => _round;
  final _round = ValueNotifier<int>(1);

  ValueListenable<RoundState> get roundState => _roundState;
  final _roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);

  ValueListenable<int> get level => _level;
  final _level = ValueNotifier<int>(1);
  ValueListenable<bool> get solo => _solo;
  final _solo = ValueNotifier<bool>(false);
  ValueListenable<String> get scenario => _scenario;
  final _scenario = ValueNotifier<String>("");

  BuiltList<String> get scenarioSectionsAdded => BuiltList.of(_scenarioSectionsAdded);
  List<String> _scenarioSectionsAdded = [];

  BuiltList<SpecialRule> get scenarioSpecialRules => BuiltList.of(_scenarioSpecialRules);
  List<SpecialRule> _scenarioSpecialRules = []; //has both monsters and characters

  LootDeck get lootDeck => _lootDeck; //todo: still mutable
  late LootDeck _lootDeck = LootDeck.empty(); //loot deck for current scenario

  ValueListenable<String> get toastMessage => _toastMessage;
  final _toastMessage = ValueNotifier<String>("");

  BuiltList<ListItemData> get currentList => BuiltList.of(_currentList);
  List<ListItemData> _currentList = []; //has both monsters and characters

  BuiltList<MonsterAbilityState> get currentAbilityDecks => BuiltList.of(_currentAbilityDecks);
  List<MonsterAbilityState> _currentAbilityDecks =
      <MonsterAbilityState>[]; //add to here when adding a monster type

  //elements
  BuiltMap<Elements, ElementState> get elementState => BuiltMap.of(_elementState);
  final Map<Elements, ElementState> _elementState = HashMap();

  //modifierDeck
  ModifierDeck get modifierDeck => _modifierDeck; //todo: still mutable
  ModifierDeck _modifierDeck = ModifierDeck("");
  ModifierDeck get modifierDeckAllies => _modifierDeckAllies; //todo: still mutable
  ModifierDeck _modifierDeckAllies = ModifierDeck("allies");

  //unlocked characters
  BuiltSet<String> get unlockedClasses => BuiltSet.of(_unlockedClasses);
  Set<String> _unlockedClasses = {};

  @override
  String toString() {
    Map<String, int> elements = {};
    for (var key in elementState.keys) {
      elements[key.index.toString()] = elementState[key]!.index;
    }

    return '{'
        '"level": ${_level.value}, '
        '"solo": ${_solo.value}, '
        '"roundState": ${_roundState.value.index}, '
        '"round": ${_round.value}, '
        '"scenario": "${_scenario.value}", '
        '"toastMessage": ${jsonEncode(_toastMessage.value)}, '
        '"scenarioSpecialRules": ${_scenarioSpecialRules.toString()}, '
        '"scenarioSectionsAdded": ${json.encode(_scenarioSectionsAdded)}, '
        '"currentCampaign": "${_currentCampaign.value}", '
        '"currentList": ${_currentList.toString()}, '
        '"currentAbilityDecks": ${_currentAbilityDecks.toString()}, '
        '"modifierDeck": ${_modifierDeck.toString()}, '
        '"modifierDeckAllies": ${_modifierDeckAllies.toString()}, '
        '"lootDeck": ${_lootDeck.toString()}, ' //does this work if null?
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
    gameSaveStates.add(
        state); //init state: means game save state is one larger than command list
  }

  Future<void> loadFromData(String data) async {
    GameSaveState state = GameSaveState();
    state.loadFromData(data);
    gameSaveStates.add(state);
    state.saveToDisk();
  }
}
