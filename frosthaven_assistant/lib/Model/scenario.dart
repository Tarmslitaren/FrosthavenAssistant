import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:frosthaven_assistant/Model/room.dart';

import '../Resource/game_methods.dart';

class LootDeckModel {
  final int lumber;
  final int hide;
  final int metal;
  final int coin;
  final int arrowvine;
  final int corpsecap;
  final int snowthistle;
  final int axenut;
  final int flamefruit;
  final int rockroot;
  final int treasure;
  LootDeckModel(this.lumber, this.hide, this.metal, this.coin, this.arrowvine, this.corpsecap, this.snowthistle, this.axenut, this.flamefruit, this.rockroot, this.treasure);

  static int _getValueFromJson(Map<String, dynamic> data, String value) {
    if(data.containsKey(value)) {
      return data[value];
    }
    return 0;
  }

  factory LootDeckModel.fromJson(Map<String, dynamic> data) {

    return LootDeckModel(
        _getValueFromJson(data, "lumber"),
      _getValueFromJson(data, "hide"),
      _getValueFromJson(data, "metal"),
      _getValueFromJson(data, "coin"),
      _getValueFromJson(data, "arrowvine"),
      _getValueFromJson(data, "corpsecap"),
      _getValueFromJson(data, "snowthistle"),
      _getValueFromJson(data, "axenut"),
      _getValueFromJson(data, "flamefruit"),
      _getValueFromJson(data, "rockroot"),
      _getValueFromJson(data, "treasure")
    );
  }
}

class SpecialRule {
  final String type;
  final String name;
  final dynamic health;
  final int level;
  final int init;
  final String note;
  final List<dynamic> list;
  final bool startOfRound;
  SpecialRule(this.type, this.name, this.health, this.level, this.init, this.note, this.list, this.startOfRound);

  factory SpecialRule.fromJson(Map<String, dynamic> data) {
    final String type = data['type']; //required
    String name = "";
    if(data.containsKey('name')) {
      name = data['name'];
    }
    dynamic health = "";
    if(data.containsKey('health')) {
      health = data['health'];
    }
    int level = 0;
    if(data.containsKey('level')) {
      level = data['level'];
    }
    int init = 99;
    if(data.containsKey('init')) {
      init = data['init'];
    }
    String note = "";
    if(data.containsKey('note')) {
      note = data['note'];
    }
    bool startOfRound = true;
    if(data.containsKey('startOfRound')) {
      startOfRound = data['startOfRound'];
    }
    List<dynamic> aList = [];
    if(data.containsKey('list')) {
      aList = data['list'];
    }
    return SpecialRule(type,name,health, level, init, note, aList, startOfRound);
  }

  //is this used at all?
  @override
  String toString() {
    return '{'
        '"type": "$type", '
        '"note": "$note", '
        '"name": "$name", '
        '"health": "$health", '
        '"init": $init, '
        '"level": $level, '
        '"startOfRound": ${startOfRound.toString()}, '
        '"list": ${jsonEncode(list)} '
        '}';
  }
}


class ScenarioModel {
  ScenarioModel({required this.name, required this.sections, required this.monsters, required this.specialRules, required this.lootDeck, required this.initMessage, required this.monsterStandees});
  String name;
  List<String> monsters;
  List<SpecialRule> specialRules;
  LootDeckModel? lootDeck;
  String initMessage;
  List<RoomMonsterData>? monsterStandees;
  final List<ScenarioModel> sections;
  factory ScenarioModel.fromJson(String name, Map<String, dynamic> data, RoomsModel? rooms) {
    List<String> monsterList = [];
    if(data.containsKey('monsters')) {
      final monsters = data['monsters'] as List<dynamic>;
      for (var monster in monsters) {
        monsterList.add(monster);
      }
    }
    List<SpecialRule> rulesList = [];
    if(data.containsKey('special')) {
      final specialRules = data['special'] as List<dynamic>;
      for(var rule in specialRules) {
        rulesList.add(SpecialRule.fromJson(rule));
      }
    }
    LootDeckModel? lootDeck;
    if(data.containsKey('lootDeck')) {
      lootDeck = LootDeckModel.fromJson(data['lootDeck']);
    }
    String initMessage = "";
    if(data.containsKey('initialMessage')) {
      initMessage = data['initialMessage'];
    }

    List<ScenarioModel> sectionList = [];

    if(rooms != null) {
      for (int i = 1; i < rooms.roomData.length; i++){ //skip first as it is the scenario start room
        sectionList.add(ScenarioModel.sectionFromRoomData(rooms.roomData[i]));
      }
    }

    if(data.containsKey("sections")) {
      final sections = data['sections'] as Map<dynamic, dynamic>;
      for (String key in sections.keys){
        if(rooms == null) {
          sectionList.add(ScenarioModel.sectionFromJson(key, sections[key], rooms));
        } else {
          //todo: it might be a bit silly that room data and section data is separate
          //merge if has already
          ScenarioModel? section = sectionList.firstWhereOrNull((element) => element.name == key.split(" ")[0]);
          if(section != null) {
            //merge
            ScenarioModel model = ScenarioModel.sectionFromJson(key, sections[key], rooms);
            section.monsters = model.monsters;
            section.initMessage = model.initMessage;
            section.specialRules = model.specialRules;

          } else {
            //this shouldn't happen (but I guess it could if there are 0 monster sections...
            print("section room name mismatch perhaps?");
            sectionList.add(ScenarioModel.sectionFromJson(key, sections[key], rooms));
          }
        }
      }
    }
    if(rooms != null && rooms.roomData.isEmpty) {
      rooms = null;
    }

    return ScenarioModel(name: name, monsters: monsterList, specialRules: rulesList, lootDeck: lootDeck, initMessage: initMessage, sections:sectionList, monsterStandees: rooms?.roomData[0].monsterData);
  }

  factory ScenarioModel.sectionFromJson(String name, Map<String, dynamic> data, RoomsModel? rooms) {
    List<String> monsterList = [];
    if(data.containsKey('monsters')) {
      final monsters = data['monsters'] as List<dynamic>;
      for (var monster in monsters) {
        monsterList.add(monster);
      }
    }
    List<SpecialRule> rulesList = [];
    if(data.containsKey('special')) {
      final specialRules = data['special'] as List<dynamic>;
      for(var rule in specialRules) {
        rulesList.add(SpecialRule.fromJson(rule));
      }
    }
    String initMessage = "";
    if(data.containsKey('initialMessage')) {
      initMessage = data['initialMessage'];
    }

    //find right room
    List<RoomMonsterData>? standees = rooms?.roomData.firstWhereOrNull((element) => element.name == GameMethods.findNrFromScenarioName(name).toString())?.monsterData;
    return ScenarioModel(name: name, monsters: monsterList, specialRules: rulesList, lootDeck: null, initMessage: initMessage, sections:[], monsterStandees: standees);
  }

  factory ScenarioModel.sectionFromRoomData(RoomModel room) {
    List<RoomMonsterData>? standees = room.monsterData;
    return ScenarioModel(name: "#${room.name}", monsters: [], specialRules: [], lootDeck: null, initMessage: "", sections:[], monsterStandees: room.monsterData);
  }

}