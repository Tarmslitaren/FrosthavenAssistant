import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Layout/main_list.dart';
import '../../Model/character_class.dart';
import '../../Model/monster.dart';
import '../../Model/monster_ability.dart';
import '../../Model/room.dart';
import '../../Model/scenario.dart';
import '../../services/network/communication.dart';
import '../../services/network/network.dart';
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../card_stack.dart';
import '../commands/add_standee_command.dart';
import '../enums.dart';
import '../game_data.dart';
import '../game_event.dart';
import '../game_methods.dart';

part "../character_methods.dart";
part "../deck_methods.dart";
part "../element_methods.dart";
part "../game_util_methods.dart";
part "../monster_methods.dart";
part "../round_methods.dart";
part "../scenario_methods.dart";
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

class GameState {
  late final ActionHandler _actionHandler;

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
  final pendingAutoAddDialog = ValueNotifier<List<RoomMonsterData>?>(null);

  List<String> _scenarioSectionsAdded = [];
  List<SpecialRule> _scenarioSpecialRules = [];
  List<ListItemData> _currentList = []; //has both monsters and characters
  final _currentListNotifier =
      ValueNotifier<BuiltList<ListItemData>>(BuiltList.of([]));
  final List<MonsterAbilityState> _currentAbilityDecks =
      <MonsterAbilityState>[];
  final Map<Elements, ElementState> _elementState = HashMap();
  Set<String> _unlockedClasses = {};

  LootDeck _lootDeck = LootDeck.empty(); //loot deck for current scenario
  final ModifierDeck _modifierDeck = ModifierDeck("");
  final ModifierDeck _modifierDeckAllies = ModifierDeck("allies");
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
  ValueListenable<BuiltList<ListItemData>> get currentListNotifier =>
      _currentListNotifier;
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

  GameState({
    required Communication communication,
    Settings? settings,
    Network? network,
  }) {
    _actionHandler = ActionHandler(
      gameState: this,
      communication: communication,
      settings: settings,
      network: network,
    );
  }

  // ActionHandler delegation — public API preserved for all callers
  void action(Command command) => _actionHandler.action(command);
  void undo() => _actionHandler.undo();
  void redo() => _actionHandler.redo();
  void updateAllUI() => _actionHandler.updateAllUI();
  Command getCurrent() => _actionHandler.getCurrent();
  void resetCommandHistory() => _actionHandler.resetCommandHistory();
  void clearLocalCommands() => _actionHandler.clearLocalCommands();
  void insertReceivedDescription(int index, String description) =>
      _actionHandler.insertReceivedDescription(index, description);
  void addSaveState(GameSaveState state) => _actionHandler.addSaveState(state);

  ValueNotifier<int> get commandIndex => _actionHandler.commandIndex;
  ValueNotifier<GameEvent> get lastEvent => _actionHandler.lastEvent;
  ValueNotifier<int> get updateList => _actionHandler.updateList;
  int get maxUndo => _actionHandler.maxUndo;
  List<Command?> get commands => _actionHandler.commands;
  List<String> get commandDescriptions => _actionHandler.commandDescriptions;
  List<GameSaveState?> get gameSaveStates => _actionHandler.gameSaveStates;

  void init() {
    _elementState[Elements.fire] = ElementState.inert;
    _elementState[Elements.ice] = ElementState.inert;
    _elementState[Elements.air] = ElementState.inert;
    _elementState[Elements.earth] = ElementState.inert;
    _elementState[Elements.light] = ElementState.inert;
    _elementState[Elements.dark] = ElementState.inert;
  }

  void setCampaign(_StateModifier _, String value) {
    _currentCampaign.value = value;
  }

  void setRoundState(_StateModifier _, RoundState value) {
    _roundState.value = value;
  }

  void setLevel(_StateModifier _, int value) {
    _level.value = value;
  }

  void setSolo(_StateModifier _, bool value) {
    _solo.value = value;
  }

  void setAutoScenarioLevel(_StateModifier _, bool value) {
    _autoScenarioLevel.value = value;
  }

  void setAllyDeckInOGGloom(_StateModifier _, bool value) {
    _allyDeckInOGGloom.value = value;
  }

  void setDifficulty(_StateModifier _, int value) {
    _difficulty.value = value;
  }

  void setScenario(_StateModifier _, String value) {
    _scenario.value = value;
  }

  void setToastMessage(_StateModifier _, String value) {
    _toastMessage.value = value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, int> elements = {};
    for (var key in _elementState.keys) {
      final state = _elementState[key];
      if (state != null) {
        elements[key.index.toString()] = state.index;
      }
    }
    return {
      'level': _level.value,
      'solo': _solo.value,
      'autoScenarioLevel': _autoScenarioLevel.value,
      'difficulty': _difficulty.value,
      'roundState': _roundState.value.index,
      'round': _round.value,
      'totalRounds': _totalRounds.value,
      'scenario': _scenario.value,
      'toastMessage': _toastMessage.value,
      'scenarioSpecialRules':
          _scenarioSpecialRules.map((r) => r.toJson()).toList(),
      'scenarioSectionsAdded': _scenarioSectionsAdded,
      'currentCampaign': _currentCampaign.value,
      'currentList': _currentList.map((item) => item.toJson()).toList(),
      'currentAbilityDecks':
          _currentAbilityDecks.map((d) => d.toJson()).toList(),
      'sanctuaryDeck': _sanctuaryDeck.toJson(),
      'modifierDeck': _modifierDeck.toJson(),
      'modifierDeckAllies': _modifierDeckAllies.toJson(),
      'lootDeck': _lootDeck.toJson(),
      'unlockedClasses': unlockedClasses.toList(),
      'showAllyDeck': showAllyDeck.value,
      'allyDeckInOGGloom': allyDeckInOGGloom.value,
      'elementState': elements,
    };
  }

  @override
  String toString() => json.encode(toJson());

  void save() {
    GameSaveState state = GameSaveState();
    state.saveToDisk(this);
    addSaveState(state);
  }

  void load() {
    GameSaveState state = GameSaveState();
    state.loadFromDisk(this);
    addSaveState(
        state); //init state: means game save state is one larger than command list
  }

  void loadFromData(String data) {
    GameSaveState state = GameSaveState();
    state.loadFromData(data, this);
  }

  /// Fires `_currentListNotifier` with the current list and also increments
  /// `updateList` so that all existing subscribers remain notified.
  void _notifyCurrentList() {
    _currentListNotifier.value = BuiltList.of(_currentList);
    updateList.value++;
  }

  /// Fires `monsterInstancesNotifier` / `summonListNotifier` on every item in
  /// the current list. Used by [updateAllUI] (redo / network sync).
  void notifyAllMonsterInstances() {
    for (var item in _currentList) {
      if (item is Monster) {
        item._notifyMonsterInstances();
      } else if (item is Character) {
        item.characterState._notifySummonList();
      }
    }
  }

  /// Clears the current list. only for use in tests. temp. should use load from data instead
  void clearList() {
    _currentList.clear();
    _notifyCurrentList();
  }
}

abstract class Command {
  //private class so only this class and it's children is allowed to change state
  _StateModifier stateAccess = _StateModifier();
  void execute();
  void onUndo() => null;
  String describe();

  /// The [GameEvent] this command produces. Defaults to [NoEvent].
  /// Override in commands that drive UI animations.
  GameEvent get event => const NoEvent();
}

class _StateModifier {}
