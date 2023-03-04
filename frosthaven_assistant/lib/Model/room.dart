class RoomMonsterData {
  String name;
  List<int> normal;
  List<int> elite;
  RoomMonsterData(this.name, this.normal, this.elite);

  factory RoomMonsterData.fromJson(Map<String, dynamic> data, String key) {
    String name = key;
    List<int> normal =  [];
    if(data.containsKey('normal')) {
      normal = data['normal'].cast<int>();
    }
    List<int> elite =  [];
    if(data.containsKey('elite')) {
      elite = data['elite'].cast<int>();
    }

    return RoomMonsterData(name, normal, elite);
  }
}

class RoomModel {
  final String name;
  final List<RoomMonsterData> monsterData;
  RoomModel(this.name, this.monsterData);

  factory RoomModel.fromJson(Map<String, dynamic> data) {

    String name = data.keys.first;
    List<RoomMonsterData> monsterList = [];
    data[name].forEach((key, value) {
      monsterList.add(RoomMonsterData.fromJson(value, key));
    });

    return RoomModel(name, monsterList);
  }
}

class RoomsModel {
  final String scenarioName;
  final List<RoomModel> roomData;
  RoomsModel(this.scenarioName, this.roomData);

  factory RoomsModel.fromJson(List<dynamic> sectionData, String scenarioName) {

    List<RoomModel> roomList = [];
    for (var value in sectionData) {
      roomList.add(RoomModel.fromJson(value));
    }

    return RoomsModel(scenarioName, roomList);
  }
}

class EditionRoomsModel {
  final List<RoomsModel> roomData;
  EditionRoomsModel( this.roomData);

  factory EditionRoomsModel.fromJson(Map<String, dynamic> data) {

    List<RoomsModel> roomList = [];
    for(var entry in data.entries) {
      roomList.add(RoomsModel.fromJson(entry.value, entry.key ));
    }

    return EditionRoomsModel( roomList);
  }
}

