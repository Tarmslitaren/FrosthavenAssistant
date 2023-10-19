import 'dart:collection';
import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Model/room.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';

@immutable
class CampaignModel {
  const CampaignModel(
      {required this.edition,
      required this.monsterAbilities,
      required this.monsters,
      required this.characters,
      required this.scenarios});
  final String edition;
  final List<MonsterAbilityDeckModel> monsterAbilities;
  final Map<String, MonsterModel> monsters;
  final List<CharacterClass> characters;
  final Map<String, ScenarioModel> scenarios;

  factory CampaignModel.fromJson(
      Map<String, dynamic> data, List<RoomsModel> roomsData) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final edition = data['edition'] as String;
    final monsterAbilities = data['monsterAbilities'] as List<dynamic>;
    List<MonsterAbilityDeckModel> deckDataList = [];
    for (var item in monsterAbilities) {
      deckDataList.add(MonsterAbilityDeckModel.fromJson(item, edition));
    }

    Map<String, MonsterModel> monsterMap = HashMap();
    final monsters = data['monsters'] as Map<dynamic, dynamic>;
    for (String key in monsters.keys) {
      monsterMap[key] = MonsterModel.fromJson(monsters[key], key, edition);
    }

    List<CharacterClass> characterDataList = [];
    final classes = data['classes'] as List<dynamic>;
    for (var item in classes) {
      characterDataList.add(CharacterClass.fromJson(item));
    }

    Map<String, ScenarioModel> scenarioMap = HashMap();
    final scenarios = data['scenarios'] as Map<dynamic, dynamic>;
    for (String key in scenarios.keys) {
      //find right room if exists

      RoomsModel? rooms = roomsData.firstWhereOrNull(
          (element) => element.scenarioName == key.substring(1).split(" ")[0]);
      scenarioMap[key] = ScenarioModel.fromJson(key, scenarios[key], rooms);
    }

    return CampaignModel(
        edition: edition,
        monsterAbilities: deckDataList,
        monsters: monsterMap,
        characters: characterDataList,
        scenarios: scenarioMap);
  }
}
