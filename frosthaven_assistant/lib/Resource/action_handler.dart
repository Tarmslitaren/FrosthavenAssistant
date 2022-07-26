import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../services/service_locator.dart';
import 'game_state.dart';

abstract class Command {
  void execute();
  void undo();
}

class ActionHandler {
  final commandIndex = ValueNotifier<int>(-1);
  final List<Command> commands = [];
  final List<GameSaveState> gameSaveStates = [];

  Command getCurrent() {
    return commands[commandIndex.value];
  }

  void undo(){
    if(commandIndex.value >= 0) {

      gameSaveStates[commandIndex.value].load(); //this works as gameSaveStates has one more entry than command list (includes load at start)
      // TODO: test when there is no initial save state
      commands[commandIndex.value].undo(); //currently undo only makes sure ui is updated...
      commandIndex.value--;

      //make sure to invalidate and rebuild all ui, since references will be broken
      getIt<GameState>().updateForUndo.value++;
    }
  }

  void redo(){
    if(commandIndex.value < commands.length-1) {
      commandIndex.value++;
      commands[commandIndex.value].execute();
      //getIt<GameState>().save(); //should save to disk, but not save in savestate list.
    }
  }

  void action(Command command){
    command.execute();
    commandIndex.value++;
    commands.insert(commandIndex.value, command);
    //remove possible redo list
    if(commands.length-1 > commandIndex.value) {
      commands.removeRange(commandIndex.value + 1, commands.length);
    }
    if (gameSaveStates.length > commandIndex.value +1) {
      //remove future game states
      gameSaveStates.removeRange(commandIndex.value + 1, gameSaveStates.length);
    }
    getIt<GameState>().save(); //save after each action ok?
  }
}