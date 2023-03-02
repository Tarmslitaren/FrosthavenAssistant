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

  factory RoomsModel.fromJson(Map<String, dynamic> data, String scenarioName) {

    List<RoomModel> roomList = [];
    List<dynamic> sectionData = data['sections'];
    for (var value in sectionData) {
      roomList.add(RoomModel.fromJson(value));
    }

    return RoomsModel(scenarioName, roomList);
  }
}
