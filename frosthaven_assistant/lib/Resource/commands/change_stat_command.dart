
import 'package:flutter/material.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_methods.dart';
import '../game_state.dart';

class ChangeStatCommand extends Command {
  final int change;
  final ValueNotifier<int> stat;
  final Figure figure;
  ChangeStatCommand(this.change, this.stat, this.figure );

  @override
  void execute() {
    stat.value += change;
    if (stat.value <= 0 && stat == figure.health) {
      handleDeath();
    }
  }

  void handleDeath(){
    for(var item in getIt<GameState>().currentList){
      if(item is Monster){
        for (var instance in item.monsterInstances.value) {
          if(instance.health.value == 0) {
            item.monsterInstances.value.remove(instance);
            if (item.monsterInstances.value.isEmpty) {
              if (getIt<GameState>().roundState.value ==
                  RoundState.chooseInitiative) {
                GameMethods.sortCharactersFirst();
              } else
              if (getIt<GameState>().roundState.value == RoundState.playTurns) {
                GameMethods.sortByInitiative();
              }
              if(getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              }else {
                getIt<GameState>().updateList.value++;
              }
            }else {
              getIt<GameState>().updateList.value++;
            }
            //Navigator.pop(context);
            break;
          }
        }
      }
    }
  }

  @override
  void undo() {
    stat.value -= change;
  }
}