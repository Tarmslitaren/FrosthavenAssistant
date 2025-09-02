import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/summon_model.dart';

@immutable
class CharacterClass {
  final String id;
  final String name;
  final String edition;
  final List<int> healthByLevel;
  final Color color;
  final Color colorSecondary;
  final bool hidden;
  final List<SummonModel> summons;
  final List<PerkModel> perks;
  final List<PerkModel> perksFH;

  const CharacterClass(
      this.id,
      this.name,
      this.healthByLevel,
      this.edition,
      this.color,
      this.colorSecondary,
      this.hidden,
      this.summons,
      this.perks,
      this.perksFH);

  factory CharacterClass.fromJson(Map<String, dynamic> data) {
    final edition = data['edition'] as String;
    final name = data['name'] as String;
    String id = name; //default to name if no id
    if (data.containsKey('id')) {
      id = data['id'] as String;
    }
    bool hidden = false;
    if (data.containsKey('hidden')) {
      hidden = data['hidden'] as bool;
    }
    //TODO: color array + gradiantType support
    final healthByLevel = (data['health'] as List<dynamic>).cast<int>();
    int radix = 16;
    var colorValue = data['color'];
    Color color = (colorValue is List<dynamic>)
        ? Color(int.parse(colorValue.first, radix: radix))
        : Color(int.parse(colorValue, radix: radix));

    Color colorSecondary = color;
    if (data.containsKey("colorSecondary")) {
      colorSecondary = (data["colorSecondary"] is List<dynamic>)
          ? colorSecondary =
              Color(int.parse(data['colorSecondary'][0], radix: radix))
          : Color(int.parse(data['colorSecondary'], radix: radix));
    }

    List<SummonModel> summonList = [];
    if (data.containsKey('summons')) {
      final summons = data['summons'] as Map<dynamic, dynamic>;
      for (String key in summons.keys) {
        summonList.add(SummonModel.fromJson(summons[key], key));
      }
    }

    List<PerkModel> perkList = [];
    if (data.containsKey('perks')) {
      final perks = data['perks'] as List<dynamic>;
      for (final item in perks) {
        perkList.add(PerkModel.fromJson(item));
      }
    }

    List<PerkModel> perkFHList = [];
    if (data.containsKey('perks_fh')) {
      final perks = data['perks_fh'] as List<dynamic>;
      for (final item in perks) {
        perkFHList.add(PerkModel.fromJson(item));
      }
    }

    return CharacterClass(id, name, healthByLevel, edition, color,
        colorSecondary, hidden, summonList, perkList, perkFHList);
  }
}

@immutable
class PerkModel {
  final String text;
  final List<String> remove;
  final List<String> add;
  const PerkModel(this.text, this.remove, this.add);

  factory PerkModel.fromJson(Map<String, dynamic> data) {
    String text = "";
    if (data.containsKey('text')) {
      text = data['text'];
    }

    List<String> addList = [];
    if (data.containsKey('adds')) {
      final adds = data['adds'] as List<dynamic>;
      for (String item in adds) {
        addList.add(item);
      }
    }

    List<String> removeList = [];
    if (data.containsKey('removes')) {
      final removes = data['removes'] as List<dynamic>;
      for (String item in removes) {
        removeList.add(item);
      }
    }

    return PerkModel(text, removeList, addList);
  }
}
