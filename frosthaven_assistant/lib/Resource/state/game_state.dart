import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Layout/main_list.dart';
import '../../Layout/menus/auto_add_standee_menu.dart';
import '../../Model/MonsterAbility.dart';
import '../../Model/character_class.dart';
import '../../Model/monster.dart';
import '../../Model/room.dart';
import '../../Model/scenario.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../card_stack.dart';
import '../commands/add_standee_command.dart';
import '../enums.dart';
import '../game_data.dart';
import '../game_methods.dart';

part "../mutable_game_methods.dart";
part "character.dart";
part "character_state.dart";
part "figure_state.dart";
part "game_save_state.dart";
part "list_item_data.dart";
part "loot_deck_state.dart";
part "modifier_deck.dart";
part "monster.dart";
part "monster_ability_state.dart";
part "monster_instance.dart";
part "sanctuary_deck.dart";

// ignore_for_file: library_private_types_in_public_api

class GameState extends ActionHandler {
  //TODO: put action handler in own place

  //state
  final _currentCampaign = ValueNotifier<String>("Jaws of the Lion");
  final _round = ValueNotifier<int>(1);
  final _totalRounds = ValueNotifier<int>(1);
  final _roundState = ValueNotifier<RoundState>(RoundState.chooseInitiative);
  final _level = ValueNotifier<int>(1);
  final _solo = ValueNotifier<bool>(false);
  final _autoScenarioLevel = ValueNotifier<bool>(false);
  final _allyDeckInOGGloom = ValueNotifier<bool>(true);
  final _difficulty = ValueNotifier<int>(1);
  final _scenario = ValueNotifier<String>("");
  final _toastMessage = ValueNotifier<String>("");
  final _showAllyDeck = ValueNotifier<bool>(false);

  List<String> _scenarioSectionsAdded = [];
  List<SpecialRule> _scenarioSpecialRules = [];
  List<ListItemData> _currentList = []; //has both monsters and characters
  final List<MonsterAbilityState> _currentAbilityDecks =
      <MonsterAbilityState>[];
  final Map<Elements, ElementState> _elementState = HashMap();
  Set<String> _unlockedClasses = {};

  late LootDeck _lootDeck = LootDeck.empty(); //loot deck for current scenario
  ModifierDeck _modifierDeck = ModifierDeck("");
  ModifierDeck _modifierDeckAllies = ModifierDeck("allies");
  SanctuaryDeck _sanctuaryDeck = SanctuaryDeck();

  ValueListenable<String> get currentCampaign => _currentCampaign;
  ValueListenable<int> get round => _round;
  ValueListenable<int> get totalRounds => _totalRounds;
  ValueListenable<RoundState> get roundState => _roundState;
  ValueListenable<int> get level => _level;
  ValueListenable<bool> get solo => _solo;
  ValueListenable<bool> get autoScenarioLevel => _autoScenarioLevel;
  ValueListenable<bool> get allyDeckInOGGloom => _allyDeckInOGGloom;
  ValueListenable<int> get difficulty => _difficulty;
  ValueListenable<String> get toastMessage => _toastMessage;
  ValueListenable<String> get scenario => _scenario;
  ValueListenable<bool> get showAllyDeck => _showAllyDeck;

  BuiltList<String> get scenarioSectionsAdded =>
      BuiltList.of(_scenarioSectionsAdded);
  BuiltList<SpecialRule> get scenarioSpecialRules =>
      BuiltList.of(_scenarioSpecialRules);
  BuiltList<ListItemData> get currentList => BuiltList.of(_currentList);
  BuiltList<MonsterAbilityState> get currentAbilityDecks =>
      BuiltList.of(_currentAbilityDecks);
  BuiltMap<Elements, ElementState> get elementState =>
      BuiltMap.of(_elementState);
  BuiltSet<String> get unlockedClasses => BuiltSet.of(_unlockedClasses);

  LootDeck get lootDeck => _lootDeck; //todo: still mutable
  ModifierDeck get modifierDeck => _modifierDeck; //todo: still mutable
  ModifierDeck get modifierDeckAllies =>
      _modifierDeckAllies; //todo: still mutable
  SanctuaryDeck get sanctuaryDeck => _sanctuaryDeck;

  GameState();

  void init() {
    _elementState[Elements.fire] = ElementState.inert;
    _elementState[Elements.ice] = ElementState.inert;
    _elementState[Elements.air] = ElementState.inert;
    _elementState[Elements.earth] = ElementState.inert;
    _elementState[Elements.light] = ElementState.inert;
    _elementState[Elements.dark] = ElementState.inert;
  }

  setCampaign(_StateModifier _, String value) {
    _currentCampaign.value = value;
  }

  setRoundState(_StateModifier _, RoundState value) {
    _roundState.value = value;
  }

  setLevel(_StateModifier _, int value) {
    _level.value = value;
  }

  setSolo(_StateModifier _, bool value) {
    _solo.value = value;
  }

  setAutoScenarioLevel(_StateModifier _, bool value) {
    _autoScenarioLevel.value = value;
  }

  setAllyDeckInOGGloom(_StateModifier _, bool value) {
    _allyDeckInOGGloom.value = value;
  }

  setDifficulty(_StateModifier _, int value) {
    _difficulty.value = value;
  }

  setScenario(_StateModifier _, String value) {
    _scenario.value = value;
  }

  setToastMessage(_StateModifier _, String value) {
    _toastMessage.value = value;
  }

  @override
  String toString() {
    Map<String, int> elements = {};
    for (var key in elementState.keys) {
      final state = elementState[key];
      if (state != null) {
        elements[key.index.toString()] = state.index;
      }
    }

    return '{'
        '"level": ${_level.value}, '
        '"solo": ${_solo.value}, '
        '"autoScenarioLevel": ${_autoScenarioLevel.value}, '
        '"difficulty": ${_difficulty.value}, '
        '"roundState": ${_roundState.value.index}, '
        '"round": ${_round.value}, '
        '"totalRounds": ${_totalRounds.value}, '
        '"scenario": "${_scenario.value}", '
        '"toastMessage": ${jsonEncode(_toastMessage.value)}, '
        '"scenarioSpecialRules": ${_scenarioSpecialRules.toString()}, '
        '"scenarioSectionsAdded": ${json.encode(_scenarioSectionsAdded)}, '
        '"currentCampaign": "${_currentCampaign.value}", '
        '"currentList": ${_currentList.toString()}, '
        '"currentAbilityDecks": ${_currentAbilityDecks.toString()}, '
        '"sanctuaryDeck": ${_sanctuaryDeck.toString()}, '
        '"modifierDeck": ${_modifierDeck.toString()}, '
        '"modifierDeckAllies": ${_modifierDeckAllies.toString()}, '
        '"lootDeck": ${_lootDeck.toString()}, ' //does this work if null?
        '"unlockedClasses": ${jsonEncode(unlockedClasses.toList())}, '
        '"showAllyDeck": ${showAllyDeck.value}, '
        '"allyDeckInOGGloom": ${allyDeckInOGGloom.value}, '
        '"elementState": ${json.encode(elements)} '
        '}';
  }

  void save() {
    GameSaveState state = GameSaveState();
    state.saveToDisk(this);
    gameSaveStates.add(state); //do this from action handler instead
  }

  Future<void> load() async {
    GameSaveState state = GameSaveState();
    state.loadFromDisk(this);
    gameSaveStates.add(
        state); //init state: means game save state is one larger than command list
  }

  loadFromData(String data) {
    GameSaveState state = GameSaveState();
    state.loadFromData(data, this);
  }

  /**
   * Clears the current list. only for use in tests. temp. should use load from data instead
   */
  void clearList() {
    _currentList.clear();
  }
}

abstract class Command {
  //private class so only this class and it's children is allowed to change state
  _StateModifier stateAccess = _StateModifier();
  void execute();
  void undo();
  String describe();
}

class _StateModifier {}
