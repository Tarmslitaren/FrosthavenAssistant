import 'package:flutter/material.dart';

@immutable
class RoomMonsterData {
  final String name;
  final List<int> normal;
  final List<int> elite;
  const RoomMonsterData(this.name, this.normal, this.elite);

  factory RoomMonsterData.fromJson(Map<String, dynamic> data, String key) {
    String name = key;
    List<int> normal = [];
    if (data.containsKey('normal')) {
      normal = data['normal'].cast<int>();
    } else {
      normal = [0,0,0];
    }
    List<int> elite = [];
    if (data.containsKey('elite')) {
      elite = data['elite'].cast<int>();
    } else {
      elite = [0,0,0];
    }

    return RoomMonsterData(name, normal, elite);
  }
}

@immutable
class RoomModel {
  final String name;
  final List<RoomMonsterData> monsterData;
  const RoomModel(this.name, this.monsterData);

  factory RoomModel.fromJson(Map<String, dynamic> data) {
    String name = data.keys.first;
    List<RoomMonsterData> monsterList = [];
    data[name].forEach((key, value) {
      monsterList.add(RoomMonsterData.fromJson(value, key));
    });

    return RoomModel(name, monsterList);
  }
}

@immutable
class RoomsModel {
  final String scenarioName;
  final List<RoomModel> roomData;
  const RoomsModel(this.scenarioName, this.roomData);

  factory RoomsModel.fromJson(List<dynamic> sectionData, String scenarioName) {
    List<RoomModel> roomList = [];
    for (var value in sectionData) {
      roomList.add(RoomModel.fromJson(value));
    }

    return RoomsModel(scenarioName, roomList);
  }
}

@immutable
class EditionRoomsModel {
  final List<RoomsModel> roomData;
  const EditionRoomsModel(this.roomData);

  factory EditionRoomsModel.fromJson(Map<String, dynamic> data) {
    List<RoomsModel> roomList = [];
    for (var entry in data.entries) {
      roomList.add(RoomsModel.fromJson(entry.value, entry.key));
    }

    return EditionRoomsModel(roomList);
  }
}
