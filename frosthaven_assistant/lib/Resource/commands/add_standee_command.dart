
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';

class SummonData {
  int standeeNr;
  String name;
  int health;
  int move;
  int attack;
  int range;
  String gfx;
  SummonData(this.standeeNr, this.name, this.health,this.move,this.attack,this.range,this.gfx);
}

class AddStandeeCommand extends Command {
  final int nr;

  //nope can't use any references: they will break on load data
  final SummonData? summon;
  final MonsterType type;
  final String ownerId;
  //final ValueNotifier<List<MonsterInstance>> monsterList;


  AddStandeeCommand(this.nr, this.summon, this.ownerId, this.type);

  @override
  void execute() {

    MonsterInstance instance;
    Monster? monster;
    if(summon == null) {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId && item is Monster) {
          monster = item;
        }
      }
      instance = MonsterInstance(nr, type, monster!);
    } else {
      instance = MonsterInstance.summon(
          summon!.standeeNr,
          type,
          summon!.name,
          summon!.health,
          summon!.move,
          summon!.attack,
          summon!.range,
          summon!.gfx);
    }

    List<MonsterInstance> newList = [];
    ValueNotifier<List<MonsterInstance>>? monsterList;
    //find list
    if(monster != null) {
      monsterList = monster.monsterInstances;
    } else {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          monsterList = (item as Character).characterState.summonList;
          break;
        }
      }
    }

    newList.addAll(monsterList!.value);
    newList.add(instance);

    if (monster != null) {
      GameMethods.sortMonsterInstances(newList);
    }
    monsterList.value = newList;
    if (monsterList.value.length == 1 && monster != null) {
      //first added
      if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst();
      } else if (getIt<GameState>().roundState.value == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck();
        GameMethods.sortByInitiative();
      }
    }
    getIt<GameState>().updateList.value++;
  }



  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    String name  = ownerId;
    if(summon != null) {
      name = summon!.name;
    }
    return "Add ${name} $nr";
  }
}