import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/summon.dart';

@immutable
class CharacterClass {
  const CharacterClass(this.name, this.healthByLevel, this.edition, this.color,
      this.colorSecondary, this.hidden, this.summons);
  final String name;
  final String edition;
  final List<int> healthByLevel;
  final Color color;
  final Color colorSecondary;
  final bool hidden;
  final List<SummonModel> summons;

  factory CharacterClass.fromJson(Map<String, dynamic> data) {
    final edition = data['edition'] as String;
    final name = data['name'] as String;
    bool hidden = false;
    if (data.containsKey('hidden')) {
      hidden = data['hidden'] as bool;
    }
    //TODO: color array + gradiantType support
    final healthByLevel = (data['health'] as List<dynamic>).cast<int>();
    int radix = 16;
    var colorValue = data['color'];
    Color color;
    if (colorValue is List<dynamic>) {
      color =
          Color(int.parse(colorValue[0], radix: radix));
    } else {
      color = Color(int.parse(colorValue, radix: radix));
    }
    Color colorSecondary = color;
    if (data.containsKey("colorSecondary")) {
      if (data["colorSecondary"] is List<dynamic>) {
        colorSecondary = Color(int.parse(data['colorSecondary'][0],
            radix: radix));
      } else {
        colorSecondary = Color(int.parse(data['colorSecondary'], radix: radix));
      }
    }

    List<SummonModel> summonList = [];
    if (data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys) {
        summonList.add(SummonModel.fromJson(summons[key], key));
      }
    }
    return CharacterClass(name, healthByLevel, edition, color, colorSecondary,
        hidden, summonList);
  }
}
