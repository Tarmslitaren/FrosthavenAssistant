class MonsterAbilityDeckModel {
  MonsterAbilityDeckModel(this.name, this.edition, this.cards);

  final String name;
  final String edition;
  final List<MonsterAbilityCardModel> cards; //need to interpret strings later on

  factory MonsterAbilityDeckModel.fromJson(Map<String, dynamic> data) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final name = data['name'] as String;
    final edition = data['edition'] as String;
    final  List<dynamic> dynamicCards = data['cards'] as List<dynamic>;
    List<MonsterAbilityCardModel> cards = [];
    for (var card in dynamicCards) {
      //["Nothing special", 384, false, 50, "%move% + 0","*.........", "%attack% + 0" ],
      String title = name;
      if(card[0] is String) {
        title = card[0] as String;
        card.removeAt(0);
      }
      int nr = card[0] as int;
      bool shuffle = card[1] as bool;
      int initiative = card[2] as int;
      List<String> lines = [];
      for (int i = 3; i < card.length; i++) {
        lines.add(card[i] as String);
      }
      cards.add(MonsterAbilityCardModel(title, nr, shuffle, initiative, lines, name));
    }
    return MonsterAbilityDeckModel(name, edition, cards);
  }
}

class MonsterAbilityCardModel {
  MonsterAbilityCardModel(this.title, this.nr, this.shuffle, this.initiative, this.lines, this.deck);
  final String deck;
  final String title;
  final int nr;
  final bool shuffle;
  final int initiative; //or String
  final List<String> lines;

  @override
  String toString() {
    return '{'
        '"nr": $nr, '
        '"deck": "$deck" '
        '}';
  }
}
/*
{
      "name": "Chaos Demon",
      "edition": "JotL",
      "cards": [
        ["Chilling Breath", 412, false, 13, "%move% - 1","*.........", "%attack% + 0 %aoe-triangle-2-side-with-black%","*.........", "%ice%%use%", "!*Any time a figure attacks the", "!*Chaos Demon this round,", "!*that figure suffers 2 damage." ],
        ["Heal Blast", 413, false, "01", "%move% + 1","*.........", "%attack% - 1", "^%range% 3", "%fire%%use%", "!%wound%" ],
        ["Seismic Punch", 414, false, 67, "%move% - 2","*.........", "%attack% + 1", "^%push% 2", "%earth%%use%", "!%aoe-triangle-2-side-with-black%" ],
        ["Whirlwind", 415, false, 20, "%move% + 0","*.........", "%attack% - 1 %aoe-triangle-2-side%", "^%range% 2","*.........", "%air%%use%", "!^%shield% 2"] ,
        ["Flashing Claws", 416, false, 41, "%move% + 0","*.........", "%attack% + 0", "^Advantage","*.........", "%light%%use%", "!%heal% 4", "!*Self" ],
        ["Black Tendrils", 417, false, 52, "%move% - 1","*.........", "%attack% + 1", "%dark%%use%", "!*All enemies adjacent to the", "!*target suffer 1 damage." ],
        ["Mana Explosion", 418, true, 76, "%move% + 0","*.........", "%attack% + 0", "%fire%%ice%%air%%earth%%light%%dark%" ],
        ["Hungry Maw", 419, true, 98, "%move% - 1","*.........", "%attack% - 1", "%any%%use%", "!%disarm%" ]
      ],
      "cardLayouts": [
        {
          "nr": 412,
          "lines": [
            {"index": 7, "type": "line","xOffset": 50, "spaceTopOffset": -16},
            {"index": 2, "type": "icon", "xOffset": -5, "yOffset": 10, "heightOffset": 0},
            {"index": 3, "type": "line", "xOffset": 0, "yOffset": 0, "spaceTopOffset": 15}
          ]
        },
        {
          "nr": 415,
          "lines": [
            {"index": 2, "type": "icon", "xOffset": -5, "yOffset": 10, "heightOffset": 0}
          ]
        }
      ]
    },
 */