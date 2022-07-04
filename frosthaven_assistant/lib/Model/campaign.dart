import 'dart:collection';
import 'dart:core';

import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/character_class.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';


class CampaignModel {
  CampaignModel({required this.edition, required this.monsterAbilities, required this.monsters, required this.characters, required this.scenarios,required this.sections});
  final String edition;
  final List<MonsterAbilityDeckModel> monsterAbilities;
  //final List<MonsterModel> monsters;
  final Map< String, MonsterModel> monsters;
  final List<CharacterClass> characters;
  final Map< String, ScenarioModel> scenarios;
  final Map< String, ScenarioModel> sections;
  //TODO: add classes and scenarios (sections are part of scenarios)

  factory CampaignModel.fromJson(Map<String, dynamic> data) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final edition = data['edition'] as String;
    final monsterAbilities = data['monsterAbilities'] as List<dynamic>;
    List<MonsterAbilityDeckModel> deckDataList = [];
    for (var item in monsterAbilities) {
      deckDataList.add(MonsterAbilityDeckModel.fromJson(item, edition));
    }
    /*final monsters = data['monsters'] as List<dynamic>;
    List<MonsterModel> monsterDataList = [];
    for (var item in monsters) {
      monsterDataList.add(MonsterModel.fromJson(item, edition));
    }*/

    Map<String, MonsterModel> monsterMap = HashMap();
    final monsters = data['monsters'] as Map<dynamic, dynamic>;
    for (String key in monsters.keys){
      monsterMap[key] = MonsterModel.fromJson(monsters[key], key, edition);
    }

    List<CharacterClass> characterDataList = [];
    final classes = data['classes'] as List<dynamic>;
    for (var item in classes) {
      characterDataList.add(CharacterClass.fromJson(item));
    }

    Map<String, ScenarioModel> scenarioMap = HashMap();
    final scenarios = data['scenarios'] as Map<dynamic, dynamic>;
    for (String key in scenarios.keys){
      scenarioMap[key] = ScenarioModel.fromJson(scenarios[key]);
    }

    Map<String, ScenarioModel> sectionMap = HashMap();
    final sections = data['sections'] as Map<dynamic, dynamic>;
    for (String key in sections.keys){
      sectionMap[key] = ScenarioModel.fromJson(sections[key]);
    }

    return CampaignModel(edition: edition, monsterAbilities: deckDataList, monsters: monsterMap, characters: characterDataList, scenarios: scenarioMap, sections: sectionMap);
  }
}