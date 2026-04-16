import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../services/network/communication.dart';
import '../services/network/network.dart';
import '../services/service_locator.dart';
import 'game_event.dart';
import 'state/game_state.dart';

class ActionHandler {
  final commandIndex = ValueNotifier<int>(-1);
  final List<Command?> _commands = [];
  final List<String> _commandDescriptions = []; //only used when connected
  final List<GameSaveState?> _gameSaveStates = [];

  List<Command?> get commands => List.unmodifiable(_commands);
  List<String> get commandDescriptions => List.unmodifiable(_commandDescriptions);
  List<GameSaveState?> get gameSaveStates => List.unmodifiable(_gameSaveStates);

  /// Resets all command/description/save-state history to a clean slate,
  /// keeping only the most recent save state as the baseline.
  void resetCommandHistory() {
    _commands.clear();
    _commandDescriptions.clear();
    if (_gameSaveStates.length > 1) {
      _gameSaveStates.removeRange(0, _gameSaveStates.length - 1);
    }
  }

  /// Clears only the local commands list (used when connecting to a server).
  void clearLocalCommands() {
    _commands.clear();
  }

  /// Inserts a description received from the network at [index].
  void insertReceivedDescription(int index, String description) {
    _commandDescriptions.insert(index, description);
  }

  /// Appends a save-state snapshot. Called by [GameState.save] and [GameState.load].
  void addSaveState(GameSaveState state) {
    _gameSaveStates.add(state);
  }

  /// The event produced by the most recent state transition.
  ///
  /// Set before [commandIndex] fires so that [commandIndex] VLB callbacks
  /// can read the correct event during their rebuild.
  final lastEvent = ValueNotifier<GameEvent>(const NoEvent());

  final int maxUndo = 250;

  final updateList = ValueNotifier<int>(0);

  final Communication _communication;
  final Settings? _settingsOverride;
  final Network? _networkOverride;

  ActionHandler({
    required Communication communication,
    Settings? settings,
    Network? network,
  })  : _communication = communication,
        _settingsOverride = settings,
        _networkOverride = network;

  Settings get _settings => _settingsOverride ?? getIt<Settings>();
  Network get _network => _networkOverride ?? getIt<Network>();

  GameState get _self => this as GameState;

  void updateAllUI() {
    _self.updateList.value++;
    _self.notifyAllMonsterInstances();
    //try to update card widget here if needed
    //try to update element buttons here if needed
  }

  Command getCurrent() {
    return _commands[commandIndex.value]!;
  }

  void undo() {
    bool isServer = _settings.server.value;
    bool isClient = _settings.client.value == ClientState.connected;
    if (!isClient) {
      if (commandIndex.value >= 0 &&
          _gameSaveStates[commandIndex.value] != null) {
        _gameSaveStates[commandIndex.value]!.load(
            _self); //this works as gameSaveStates has one more entry than command list (includes load at start)
        _gameSaveStates[commandIndex.value]!.saveToDisk(_self);
        if (!isServer && !isClient) {
          _commands[commandIndex.value]!
              .onUndo(); //undo only makes sure ui is updated
        } else {
          updateAllUI();
          //run generic update all function instead, as commands list is not retained

          //send last game state if connected
          if (isServer) {
            log('server sends, undo index: ${commandIndex.value}, description:${_commandDescriptions[commandIndex.value]}');
            //should send a special undo message? yes
            _network.server.send(
                "Index:${commandIndex.value}Description:${_commandDescriptions[commandIndex.value]}Event:${const NoEvent().toJsonString()}GameState:${_gameSaveStates[commandIndex.value]!.getState()}");
          }
        }
        lastEvent.value = const NoEvent();
        commandIndex.value--;
      }
    } else {
      _communication.sendToAll("undo");
    }
  }

  void redo() {
    bool isServer = _settings.server.value;
    bool isClient = _settings.client.value == ClientState.connected;
    if (!isClient) {
      if (commandIndex.value < _commandDescriptions.length - 1) {
        lastEvent.value = const NoEvent();
        commandIndex.value++;
        _gameSaveStates[commandIndex.value + 1]!.load(_self);
        _gameSaveStates[commandIndex.value + 1]!.saveToDisk(_self);
        //also run generic update ui function
        updateAllUI();
      } else {
        //just send message to server
        _communication.sendToAll("redo");
      }

      //send last game state if connected
      if (isServer) {
        log('server sends, redo index: ${commandIndex.value}, description:${_commandDescriptions[commandIndex.value]}');
        _network.server.send(
            "Index:${commandIndex.value}Description:${_commandDescriptions[commandIndex.value]}Event:${const NoEvent().toJsonString()}GameState:${_gameSaveStates[commandIndex.value + 1]!.getState()}");
      }
    } else if (isClient) {
      _communication.sendToAll("redo");
    }
  }

  void action(Command command) {
    bool isServer = _settings.server.value;
    bool isClient = _settings.client.value == ClientState.connected;

    command.execute();
    if (_commands.length > commandIndex.value) {
      _commands.insert(commandIndex.value + 1, command);
      _commandDescriptions.insert(commandIndex.value + 1, command.describe());
    } else {
      _commands.add(command);
      _commandDescriptions.add(command.describe());
    }

    // Set event before commandIndex fires so VLB callbacks see the correct value.
    lastEvent.value = command.event;
    commandIndex.value++;

    //remove possible redo list
    if (_commands.length - 1 > commandIndex.value) {
      _commands.removeRange(commandIndex.value + 1, _commands.length);
      _commandDescriptions.removeRange(
          commandIndex.value + 1, _commandDescriptions.length);
    }
    if (_gameSaveStates.length > commandIndex.value + 1) {
      //remove future game states
      _gameSaveStates.removeRange(commandIndex.value + 1, _gameSaveStates.length);
    }

    _self.save(); //save after each action

    //send last game state if connected
    String description = command.describe();
    String eventJson = command.event.toJsonString();
    if (isServer) {
      log('server sends, index: ${commandIndex.value}, description:$description');
      _network.server.send(
          "Index:${commandIndex.value}Description:${description}Event:${eventJson}GameState:${_self.toString()}");
    } else if (isClient) {
      log('client sends, index: ${commandIndex.value}, description:$description');
      _communication.sendToAll(
          "Index:${commandIndex.value}Description:${description}Event:${eventJson}GameState:${_self.toString()}");
    }

    //TODO: this is breaking if command index is not in sync with commands. and in connected state.
    //really need to go over this again: do we really need to save commands at all, or are save states + descriptions enough also for offline?
    if (commandIndex.value >= maxUndo) {
      if (_commands.length > commandIndex.value) {
        _commands[commandIndex.value - maxUndo] = null;
      }
      if (_gameSaveStates.length > commandIndex.value - maxUndo) {
        _gameSaveStates[commandIndex.value - maxUndo] = null;
      }
    }
  }
}
