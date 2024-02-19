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
  final _communication = getIt<Communication>();

  final int maxUndo = 250;

  void updateAllUI() {
    getIt<GameState>().updateList.value++;
    getIt<GameState>().updateForUndo.value++;
    getIt<GameState>().killMonsterStandee.value++;
    //try to update card widget here if needed
    //try to update element buttons here if needed
  }

  Command getCurrent() {
    return commands[commandIndex.value]!;
  }

  void undo() {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value == ClientState.connected;
    if (!isClient) {
      if (commandIndex.value >= 0 && gameSaveStates[commandIndex.value] != null) {
        gameSaveStates[commandIndex.value]!.load(getIt<
            GameState>()); //this works as gameSaveStates has one more entry than command list (includes load at start)
        gameSaveStates[commandIndex.value]!.saveToDisk(getIt<GameState>());
        if (!isServer && !isClient) {
          commands[commandIndex.value]!.undo(); //undo only makes sure ui is updated
        } else {
          updateAllUI();
          //run generic update all function instead, as commands list is not retained

          //send last game state if connected
          if (isServer) {
            log('server sends, undo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
            //should send a special undo message? yes
            getIt<Network>().server.send(
                "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates[commandIndex.value]!.getState()}");
          }
        }
        commandIndex.value--;

        //make sure to invalidate and rebuild all ui, since references will be broken
        getIt<GameState>().updateForUndo.value++;
      }
    } else {
      _communication.sendToAll("undo");
    }
  }

  void redo() {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value == ClientState.connected;
    if (!isClient) {
      if (commandIndex.value < commandDescriptions.length - 1) {
        commandIndex.value++;
        gameSaveStates[commandIndex.value + 1]!.load(getIt<GameState>());
        gameSaveStates[commandIndex.value + 1]!.saveToDisk(getIt<GameState>());
        //also run generic update ui function
        updateAllUI();
      } else {
        //just send message to server
        _communication.sendToAll("redo");
      }

      //send last game state if connected
      if (isServer) {
        log('server sends, redo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        getIt<Network>().server.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates[commandIndex.value + 1]!.getState()}");
      }
    } else if (isClient) {
      _communication.sendToAll("redo");
    }
  }

  void action(Command command) {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value == ClientState.connected;

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
      commandDescriptions.removeRange(commandIndex.value + 1, commandDescriptions.length);
    }
    if (gameSaveStates.length > commandIndex.value + 1) {
      //remove future game states
      gameSaveStates.removeRange(commandIndex.value + 1, gameSaveStates.length);
    }
    getIt<GameState>().save(); //save after each action

    //send last game state if connected
    if (isServer) {
      log('server sends, index: ${commandIndex.value}, description:${command.describe()}');
      getIt<Network>().server.send(
          "Index:${commandIndex.value}Description:${command.describe()}GameState:${gameSaveStates.last!.getState()}");
    } else if (isClient) {
      log('client sends, index: ${commandIndex.value}, description:${command.describe()}');
      _communication.sendToAll(
          "Index:${commandIndex.value}Description:${command.describe()}GameState:${gameSaveStates.last!.getState()}");
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
