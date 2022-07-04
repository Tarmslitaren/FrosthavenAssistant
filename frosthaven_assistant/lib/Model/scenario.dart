class ScenarioModel {
  ScenarioModel({required this.monsters});
  List<String> monsters;
  factory ScenarioModel.fromJson(Map<String, dynamic> data) {
    final monsters = data['monsters'] as List<dynamic>;
    List<String> monsterList = [];
    for (var monster in monsters) {
      monsterList.add(monster);
    }
    //TODO: add other scensrio stuff like special rules and sections
    return ScenarioModel(monsters: monsterList);
  }

}