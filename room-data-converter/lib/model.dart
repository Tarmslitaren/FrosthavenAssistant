
import 'dart:convert';

class Monster {
  Monster(this.normal, this.elite);
  List<int> normal = [];
  List<int> elite = [];


  Map<String, dynamic> toJson() {
    return {
      'normal': normal,
      'elite': elite,
    };
  }

  @override
  String toString() {
    return "\"normal\": ${jsonEncode(normal)},\n"
        "\"elite\": ${jsonEncode(elite)},";
  }
}


class Scenario {
  List<Map<String, Map<String, Monster>>> sections = [];


  Map<String, dynamic> toJson() {
    return {
      'sections': sections
    };
  }

  @override
  String toString() {
    return jsonEncode(sections);
  }

}