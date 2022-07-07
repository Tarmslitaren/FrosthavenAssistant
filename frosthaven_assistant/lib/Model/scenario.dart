class SpecialRule {
  final String type;
  final String name;
  final dynamic health;
  final int level;
  final String note;
  SpecialRule(this.type, this.name, this.health, this.level, this.note);

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
    String note = "";
    if(data.containsKey('note')) {
      note = data['note'];
    }
    return SpecialRule(type,name,health, level,note );
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