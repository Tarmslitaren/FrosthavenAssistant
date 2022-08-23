class SpecialRule {
  final String type;
  final String name;
  final dynamic health;
  final int level;
  final int init;
  final String note;
  final List<dynamic> list;
  SpecialRule(this.type, this.name, this.health, this.level, this.init, this.note, this.list);

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
    List<dynamic> aList = [];
    if(data.containsKey('list')) {
      aList = data['list'];
    }
    return SpecialRule(type,name,health, level, init, note, aList);
  }
}


class ScenarioModel {
  ScenarioModel({required this.monsters, required this.specialRules});
  List<String> monsters;
  List<SpecialRule> specialRules;
  factory ScenarioModel.fromJson(Map<String, dynamic> data) {
    final monsters = data['monsters'] as List<dynamic>;
    List<String> monsterList = [];
    for (var monster in monsters) {
      monsterList.add(monster);
    }
    List<SpecialRule> rulesList = [];
    if(data.containsKey('special')) {
      final specialRules = data['special'] as List<dynamic>;
      for(var rule in specialRules) {
        rulesList.add(SpecialRule.fromJson(rule));
      }
    }

    return ScenarioModel(monsters: monsterList, specialRules: rulesList);
  }

}