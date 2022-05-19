import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../services/service_locator.dart';
import 'game_state.dart';

//commands: draw, next round, add/remove char, add/remove monster, set initiative, etc

abstract class Command {
  void execute();
  void undo();
}

class ActionHandler {
  final commandIndex = ValueNotifier<int>(-1);
  final List<Command> commands = [];

  Command getCurrent() {
    return commands[commandIndex.value];
  }

  void undo(){
    if(commandIndex.value >= 0) {
      commands[commandIndex.value].undo();
      commandIndex.value--;
    }
  }

  void redo(){
    if(commandIndex.value < commands.length-1) {
      commandIndex.value++;
      commands[commandIndex.value].execute();
    }
  }

  void action(Command command){
    command.execute();
    commandIndex.value++;
    commands.insert(commandIndex.value, command);
    //remove possible redo list
    if(commands.length-1 > commandIndex.value) {
      commands.removeRange(commandIndex.value + 1, commands.length - 1);
    }
  }
}