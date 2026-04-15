import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';

import '../services/network/communication.dart';
import '../services/network/network.dart';
import '../services/service_locator.dart';
import 'state/game_state.dart';

class ActionHandler {
  final commandIndex = ValueNotifier<int>(-1);
  final List<Command?> commands = [];
  final List<String> commandDescriptions = []; //only used when connected
  final List<GameSaveState?> gameSaveStates = [];

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
    return commands[commandIndex.value]!;
  }

  void undo() {
    bool isServer = _settings.server.value;
    bool isClient = _settings.client.value == ClientState.connected;
    if (!isClient) {
      if (commandIndex.value >= 0 &&
          gameSaveStates[commandIndex.value] != null) {
        gameSaveStates[commandIndex.value]!.load(
            _self); //this works as gameSaveStates has one more entry than command list (includes load at start)
        gameSaveStates[commandIndex.value]!.saveToDisk(_self);
        if (!isServer && !isClient) {
          commands[commandIndex.value]!
              .onUndo(); //undo only makes sure ui is updated
        } else {
          updateAllUI();
          //run generic update all function instead, as commands list is not retained

          //send last game state if connected
          if (isServer) {
            log('server sends, undo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
            //should send a special undo message? yes
            _network.server.send(
                "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates[commandIndex.value]!.getState()}");
          }
        }
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
      if (commandIndex.value < commandDescriptions.length - 1) {
        commandIndex.value++;
        gameSaveStates[commandIndex.value + 1]!.load(_self);
        gameSaveStates[commandIndex.value + 1]!.saveToDisk(_self);
        //also run generic update ui function
        updateAllUI();
      } else {
        //just send message to server
        _communication.sendToAll("redo");
      }

      //send last game state if connected
      if (isServer) {
        log('server sends, redo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        _network.server.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates[commandIndex.value + 1]!.getState()}");
      }
    } else if (isClient) {
      _communication.sendToAll("redo");
    }
  }

  void action(Command command) {
    bool isServer = _settings.server.value;
    bool isClient = _settings.client.value == ClientState.connected;

    command.execute();
    if (commands.length > commandIndex.value) {
      commands.insert(commandIndex.value + 1, command);
      commandDescriptions.insert(commandIndex.value + 1, command.describe());
    } else {
      commands.add(command);
      commandDescriptions.add(command.describe());
    }
    commandIndex.value++;
    //remove possible redo list
    if (commands.length - 1 > commandIndex.value) {
      commands.removeRange(commandIndex.value + 1, commands.length);
      commandDescriptions.removeRange(
          commandIndex.value + 1, commandDescriptions.length);
    }
    if (gameSaveStates.length > commandIndex.value + 1) {
      //remove future game states
      gameSaveStates.removeRange(commandIndex.value + 1, gameSaveStates.length);
    }

    _self.save(); //save after each action

    //send last game state if connected
    String description = command.describe();
    if (isServer) {
      log('server sends, index: ${commandIndex.value}, description:$description');
      _network.server.send(
          "Index:${commandIndex.value}Description:${description}GameState:${_self.toString()}");
    } else if (isClient) {
      log('client sends, index: ${commandIndex.value}, description:$description');
      _communication.sendToAll(
          "Index:${commandIndex.value}Description:${description}GameState:${_self.toString()}");
    }

    //TODO: this is breaking if command index is not in sync with commands. and in connected state.
    //really need to go over this again: do we really need to save commands at all, or are save states + descriptions enough also for offline?
    if (commandIndex.value >= maxUndo) {
      if (commands.length > commandIndex.value) {
        commands[commandIndex.value - maxUndo] = null;
      }
      if (gameSaveStates.length > commandIndex.value - maxUndo) {
        gameSaveStates[commandIndex.value - maxUndo] = null;
      }
    }
  }
}
