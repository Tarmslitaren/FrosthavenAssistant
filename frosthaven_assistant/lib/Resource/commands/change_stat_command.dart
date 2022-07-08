
import 'package:flutter/material.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
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

    //lower healh if max health lowers
    if (stat.value < figure.health.value && stat == figure.maxHealth) {
      figure.health.value = figure.maxHealth.value;
    }

    //if health same as maxhealth, then let health follow?
    if (stat.value - change ==  figure.health.value && stat == figure.maxHealth) {
      figure.health.value = figure.maxHealth.value;
    }


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
            Future.delayed(Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

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
            }
            break;
          }
        }
      } else if (item is Character) {
        //handle summon death
        for (var instance in item.characterState.summonList.value) {
          if(instance.health.value == 0) {
            item.characterState.summonList.value.remove(instance);
            Future.delayed(Duration(milliseconds: 600), () {
              getIt<GameState>().killMonsterStandee.value++;
            });

            if (item.characterState.summonList.value.isEmpty) {
              //TODO: unessessary?
              if(getIt<GameState>().roundState.value == RoundState.playTurns) {
                Future.delayed(Duration(milliseconds: 600), () {
                  getIt<GameState>().updateList.value++;
                });
              }else {
                getIt<GameState>().updateList.value++;
              }
              ////
            }else {
              //getIt<GameState>().updateList.value++;
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