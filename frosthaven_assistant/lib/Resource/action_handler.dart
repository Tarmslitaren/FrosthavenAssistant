import 'package:flutter/cupertino.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import '../services/network/client.dart';
import '../services/network/network.dart';
import '../services/network/server.dart';
import '../services/service_locator.dart';
import 'game_state.dart';

abstract class Command {
  void execute();

  void undo();

  String describe();
}

class ActionHandler {
  final commandIndex = ValueNotifier<int>(-1);
  final List<Command?> commands = [];
  final List<String> commandDescriptions = []; //only used when connected
  final List<GameSaveState?> gameSaveStates = [];

  final int maxUndo = 500;

  void updateAllUI() {
    getIt<GameState>().updateList.value++;
    getIt<GameState>().updateForUndo.value++; //too harsh?
    getIt<GameState>().killMonsterStandee.value++;
    //try to update card widget her eif needed

    //try to update element buttons here if needed
  }

  Command getCurrent() {
    return commands[commandIndex.value]!;
  }

  void undo() {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value;
    if (commandIndex.value >= 0) {
      gameSaveStates[commandIndex.value]!
          .load(); //this works as gameSaveStates has one more entry than command list (includes load at start)
      gameSaveStates[commandIndex.value]!.saveToDisk();
      if (!isServer && !isClient) {
        commands[commandIndex.value]!
            .undo(); //currently undo only makes sure ui is updated...
      } else {
        updateAllUI();
        //run generic update all function instead, as commands list is not retained
      }
      commandIndex.value--;

      //make sure to invalidate and rebuild all ui, since references will be broken
      getIt<GameState>().updateForUndo.value++;

      //send last gamestate if connected
       if(isServer) {
        print(
            'server sends, undo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        getIt<Network>().server.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates.last!.getState()}");
      }
       //only allow server to undo
      /*else if (isClient) {
        print(
            'client sends, undo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        client.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates.last.getState()}");
      }*/

    }
  }

  void redo() {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value;
    if (commandIndex.value < commandDescriptions.length - 1) {
      commandIndex.value++;
      //if (!isServer && !isClient) {
      //  commands[commandIndex.value].execute();
     // } else {
        gameSaveStates[commandIndex.value+1]!.load(); //test this over network again
      gameSaveStates[commandIndex.value+1]!.saveToDisk();
        //also run generic update ui function
        updateAllUI();

      //send last gamestate if connected
      if (isServer) {
        print(
            'server sends, redo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        getIt<Network>().server.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates.last!.getState()}");
      }
      //only allow server to redo
      /*else if (isClient) {
        print(
            'client sends, redo index: ${commandIndex.value}, description:${commandDescriptions[commandIndex.value]}');
        client.send(
            "Index:${commandIndex.value}Description:${commandDescriptions[commandIndex.value]}GameState:${gameSaveStates.last.getState()}");
      }*/

      //}
    }
  }

  void action(Command command) {
    bool isServer = getIt<Settings>().server.value;
    bool isClient = getIt<Settings>().client.value;

    command.execute();
    if (commands.length >= commandIndex.value) {
      commands.insert(commandIndex.value + 1, command);
      commandDescriptions.insert(commandIndex.value + 1, command.describe());
    } else {
      commands.add(command);
      commandDescriptions.add(command.describe());
    }
    commandIndex.value++; //just moved this. hope it doesn't come with severe bugs...
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
    getIt<GameState>().save(); //save after each action?

    if(commandIndex.value >= maxUndo) {
      commands[commandIndex.value-maxUndo] = null;
      gameSaveStates[commandIndex.value-maxUndo] = null;
    }

    //send last gamestate if connected
    if (isServer) {
      print(
          'server sends, index: ${commandIndex.value}, description:${command.describe()}');
      getIt<Network>().server.send(
          "Index:${commandIndex.value}Description:${command.describe()}GameState:${gameSaveStates.last!.getState()}");
    } else if (isClient) {
      print(
          'client sends, index: ${commandIndex.value}, description:${command.describe()}');
      getIt<Network>().client.send(
          "Index:${commandIndex.value}Description:${command.describe()}GameState:${gameSaveStates.last!.getState()}");
    }
  }
}
