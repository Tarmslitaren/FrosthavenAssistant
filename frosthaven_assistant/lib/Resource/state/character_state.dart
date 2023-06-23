import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../enums.dart';
import 'figure_state.dart';
import 'monster_instance.dart';

class CharacterState extends FigureState {
  CharacterState();

  final display = ValueNotifier<String>("");
  final initiative = ValueNotifier<int>(0);
  final xp = ValueNotifier<int>(0);

  final summonList = ValueNotifier<List<MonsterInstance>>([]);

  @override
  String toString() {
    return '{'
        '"initiative": ${initiative.value}, '
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"xp": ${xp.value}, '
        '"chill": ${chill.value}, '
        '"display": ${jsonEncode(display.value)}, '
        '"summonList": ${summonList.value.toString()}, '
        '"conditions": ${conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${conditionsAddedThisTurn.value.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${conditionsAddedPreviousTurn.value.toList().toString()} '
        '}';
  }

  CharacterState.fromJson(Map<String, dynamic> json) {
    initiative.value = json['initiative'];
    xp.value = json['xp'];
    chill.value = json['chill'];
    health.value = json["health"];
    level.value = json["level"];
    maxHealth.value = json["maxHealth"];
    display.value = json['display'];

    List<dynamic> summons = json["summonList"];
    for (var item in summons) {
      summonList.value.add(MonsterInstance.fromJson(item));
    }

    List<dynamic> condis = json["conditions"];
    for (int item in condis) {
      conditions.value.add(Condition.values[item]);
    }

    if (json.containsKey("conditionsAddedThisTurn")) {
      List<dynamic> condis2 = json["conditionsAddedThisTurn"];
      for (int item in condis2) {
        conditionsAddedThisTurn.value.add(Condition.values[item]);
      }
    }
    if (json.containsKey("conditionsAddedPreviousTurn")) {
      List<dynamic> condis3 = json["conditionsAddedPreviousTurn"];
      for (int item in condis3) {
        conditionsAddedPreviousTurn.value.add(Condition.values[item]);
      }
    }
  }
}
