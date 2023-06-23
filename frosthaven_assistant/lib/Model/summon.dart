import 'package:flutter/material.dart';

@immutable
class SummonModel {
  final String name;
  final dynamic health;
  final int move;
  final int attack;
  final int range;
  final int level;
  final String gfx;
  final int standees;
  const SummonModel(this.name, this.health, this.move, this.attack, this.range,
      this.level, this.gfx, this.standees);

  factory SummonModel.fromJson(Map<String, dynamic> data, String key) {
    String name = key;
    dynamic health = 2; //default to 2 not to die
    if (data.containsKey('health')) {
      health = data['health'];
    }
    int move = 0;
    if (data.containsKey('move')) {
      move = data['move'];
    }
    int attack = 0;
    if (data.containsKey('attack')) {
      attack = data['attack'];
    }
    int range = 0;
    if (data.containsKey('attack')) {
      attack = data['attack'];
    }
    int level = 0;
    if (data.containsKey('level')) {
      level = data['level'];
    }
    String gfx = "";
    if (data.containsKey('gfx')) {
      gfx = data['gfx'];
    }

    int standees = 1;
    if (data.containsKey('standees')) {
      standees = data['standees'];
    }

    return SummonModel(name, health, move, attack, range, level, gfx, standees);
  }
}
