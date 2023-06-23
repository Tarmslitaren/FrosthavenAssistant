import 'package:flutter/widgets.dart';

import '../../Model/monster.dart';
import '../../services/service_locator.dart';
import '../enums.dart';
import 'game_state.dart';
import 'list_item_data.dart';
import 'monster_instance.dart';

class Monster extends ListItemData {
  Monster(String name, int level, {required bool isAlly}) : isAlly = isAlly {
    id = name;
    this.isAlly = isAlly;
    this.level.value = level;
    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys) {
      monsters.addAll(gameState.modelData.value[key]!.monsters);
    }
    for (String key in monsters.keys) {
      if (key == name) {
        type = monsters[key]!;
      }
    }

    GameMethods.addAbilityDeck(this);
  }
  late final MonsterModel type;
  final monsterInstances = ValueNotifier<List<MonsterInstance>>([]);
  final level = ValueNotifier<int>(0);
  bool isAlly;
  //note: this is only used for the no standee tracking setting
  bool isActive = false;

  bool hasElites() {
    for (var instance in monsterInstances.value) {
      if (instance.type == MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  //includes boss
  bool hasNormal() {
    for (var instance in monsterInstances.value) {
      if (instance.type != MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  void setLevel(int level) {
    this.level.value = level;
    for (var item in monsterInstances.value) {
      item.setLevel(this);
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.index}, '
        '"isActive": $isActive, '
        '"type": "${type.name}", '
        '"monsterInstances": ${monsterInstances.value.toString()}, '
        //'"state": ${state.index}, '
        '"isAlly": $isAlly, '
        '"level": ${level.value} '
        '}';
  }

  Monster.fromJson(Map<String, dynamic> json) : isAlly = false {
    id = json['id'];
    turnState = TurnsState.values[json['turnState']];
    level.value = json['level'];
    if (json.containsKey("isAlly")) {
      isAlly = json['isAlly'];
    }
    if (json.containsKey("isActive")) {
      isActive = json['isActive'];
    }
    String modelName = json['type'];
    //state = ListItemState.values[json["state"]];

    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys) {
      monsters.addAll(gameState.modelData.value[key]!.monsters);
    }
    for (var item in monsters.keys) {
      if (item == modelName) {
        type = monsters[item]!;
        break;
      }
    }

    List<dynamic> instanceList = json["monsterInstances"];

    List<MonsterInstance> newList = [];
    for (Map<String, dynamic> item in instanceList) {
      var instance = MonsterInstance.fromJson(item);
      newList.add(instance);
    }
    monsterInstances.value = newList;
  }
}
