library game_state;

import '../card_stack.dart';
import '../game_data.dart';
import '../enums.dart';

import 'package:built_collection/built_collection.dart';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../Layout/main_list.dart';
import '../../Model/room.dart';
import '../../Model/scenario.dart';
import '../action_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/MonsterAbility.dart';
import '../../services/service_locator.dart';

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import '../../Layout/menus/auto_add_standee_menu.dart';
import '../../Model/character_class.dart';
import '../../Model/monster.dart';
import '../commands/add_standee_command.dart';

part "game_save_state.dart";
part "character.dart";
part "character_state.dart";
part "figure_state.dart";
part "loot_deck_state.dart";
part "modifier_deck_state.dart";
part "monster.dart";
part "monster_ability_state.dart";
part "monster_instance.dart";
part "list_item_data.dart";
part "../game_methods.dart";

// ignore_for_file: library_private_types_in_public_api

abstract class Command {
  void execute();
  void undo();
  String describe();

  //private class so only this class and it's children is allowed to change state
  _StateModifier stateAccess = _StateModifier();
}

class _StateModifier {}

class GameState extends ActionHandler {
  //TODO: put action handler in own place

  GameState() {
  }

  void init() {

    _elementState[Elements.fire] = ElementState.inert;
    _elementState[Elements.ice] = ElementState.inert;
    _elementState[Elements.air] = ElementState.inert;
    _elementState[Elements.earth] = ElementState.inert;
    _elementState[Elements.light] = ElementState.inert;
    _elementState[Elements.dark] = ElementState.inert;

  }


  //todo: ugly hacks to delay list update (doesn't need to be here though)
  final updateList = ValueNotifier<int>(0);
  final killMonsterStandee = ValueNotifier<int>(-1);
  final updateForUndo = ValueNotifier<int>(0);

  //state
  ValueListenable<String> get currentCampaign => _currentCampaign;
  final _currentCampaign = ValueNotifier<String>("Jaws of the Lion");
  setCampaign(_StateModifier stateModifier, String value) {_currentCampaign.value = value;}

  ValueListenable<int> get round => _round;
  final _round = ValueNotifier<int>(1);
  setRound(_StateModifier stateModifier, int value) {_round.value = value;}

  ValueListenable<RoundState> get roundState => _roundState;
  final _roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);
  setRoundState(_StateModifier stateModifier, RoundState value) {_roundState.value = value;}

  ValueListenable<int> get level => _level;
  final _level = ValueNotifier<int>(1);
  setLevel(_StateModifier stateModifier, int value) {_level.value = value;}
  ValueListenable<bool> get solo => _solo;
  final _solo = ValueNotifier<bool>(false);
  setSolo(_StateModifier stateModifier, bool value) {_solo.value = value;}
  ValueListenable<String> get scenario => _scenario;
  final _scenario = ValueNotifier<String>("");
  setScenario(_StateModifier stateModifier, String value) {_scenario.value = value;}

  BuiltList<String> get scenarioSectionsAdded => BuiltList.of(_scenarioSectionsAdded);
  List<String> _scenarioSectionsAdded = [];

  BuiltList<SpecialRule> get scenarioSpecialRules =>
      BuiltList.of(_scenarioSpecialRules);
  List<SpecialRule> _scenarioSpecialRules =
      []; //has both monsters and characters

  LootDeck get lootDeck => _lootDeck; //todo: still mutable
  late LootDeck _lootDeck = LootDeck.empty(); //loot deck for current scenario

  ValueListenable<String> get toastMessage => _toastMessage;
  final _toastMessage = ValueNotifier<String>("");
  setToastMessage(_StateModifier stateModifier, String value) {_toastMessage.value = value;}

  BuiltList<ListItemData> get currentList => BuiltList.of(_currentList);
  List<ListItemData> _currentList = []; //has both monsters and characters

  BuiltList<MonsterAbilityState> get currentAbilityDecks => BuiltList.of(_currentAbilityDecks);
  List<MonsterAbilityState> _currentAbilityDecks = <MonsterAbilityState>[];
  //add to here when adding a monster type

  //elements
  BuiltMap<Elements, ElementState> get elementState => BuiltMap.of(_elementState);
  final Map<Elements, ElementState> _elementState = HashMap();

  //modifierDeck
  ModifierDeck get modifierDeck => _modifierDeck; //todo: still mutable
  ModifierDeck _modifierDeck = ModifierDeck("");
  ModifierDeck get modifierDeckAllies =>
      _modifierDeckAllies; //todo: still mutable
  ModifierDeck _modifierDeckAllies = ModifierDeck("allies");

  //unlocked characters
  BuiltSet<String> get unlockedClasses => BuiltSet.of(_unlockedClasses);
  Set<String> _unlockedClasses = {};

  final showAllyDeck = ValueNotifier<bool>(false);


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
        '"showAllyDeck": ${showAllyDeck.value}, '
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
