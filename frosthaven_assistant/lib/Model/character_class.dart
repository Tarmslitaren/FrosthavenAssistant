import 'dart:ui';

import 'package:frosthaven_assistant/Model/summon.dart';

class CharacterClass {
  CharacterClass(this.name, this.healthByLevel, this.edition, this.color, this.colorSecondary, this.hidden, this.summons);
  final String name;
  final String edition;
  final List<int> healthByLevel;
  final Color color;
  final Color colorSecondary;
  final bool hidden;
  final List<SummonModel> summons;

  factory CharacterClass.fromJson(Map<String, dynamic> data) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final edition = data['edition'] as String;
    final name = data['name'] as String;
    bool hidden = false;
    if(data.containsKey('hidden')) {
      hidden = data['hidden'] as bool;
    }
    final healthByLevel = (data['health'] as List<dynamic>).cast<int>();
    var colorValue = data['color']; //this can be both string and signed int
    if(colorValue is int) {
      colorValue = colorValue.toString();
    }
    int radix = 16;
    int value = int.parse(colorValue, radix: radix);
    Color color = Color(value);
    Color colorSecondary = color;
    if(data.containsKey("colorSecondary")) {
      colorSecondary = Color(int.parse(data['colorSecondary'], radix: radix));
    }

    List<SummonModel> summonList = [];
    if(data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys){
        summonList.add(SummonModel.fromJson(summons[key], key));
      }
    }
    return CharacterClass(name, healthByLevel, edition, color, colorSecondary, hidden, summonList);
  }
}