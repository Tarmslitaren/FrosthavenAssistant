
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
  final Monster? monster;
  final SummonData? summon;
  final MonsterType type;
  final ValueNotifier<List<MonsterInstance>> monsterList;

  AddStandeeCommand(this.nr, this.monster, this.summon, this.monsterList, this.type);

  @override
  void execute() {

    MonsterInstance instance;
    if(monster != null) {
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
    newList.addAll(monsterList.value);
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
    // TODO: implement undo
  }
}