part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class MonsterInstance extends FigureState {
  MonsterInstance(this.standeeNr, this._type, bool summoned, Monster monster) {
    _setLevel(monster);
    gfx = monster.type.gfx;
    name = monster.type.name;
    move = 0; //only used for summons
    attack = 0;
    range = 0;
    if (summoned) {
      _roundSummoned = getIt<GameState>().round.value;
    } else {
      _roundSummoned = -1;
    }
  }

  MonsterInstance.summon(
      this.standeeNr,
      this._type,
      this.name,
      int summonHealth,
      this.move,
      this.attack,
      this.range,
      this.gfx,
      this._roundSummoned) {
    //deal with summon init
    _maxHealth.value = summonHealth;
    _health.value = summonHealth;
  }

  String getId() {
    return name + gfx + standeeNr.toString();
  }

  late final int standeeNr;

  setType(_StateModifier stateModifier, MonsterType value) {
    _type = value;
  }

  MonsterType get type => _type;
  late MonsterType _type; //can't be fina due to ice wraith special
  late final String name;
  late final String gfx;

  //summon stats. not used currently
  late final int move;
  late final int attack;
  late final int range;

  int get roundSummoned => _roundSummoned;
  setRoundSummoned(_StateModifier stateModifier, int value) {
    _roundSummoned = value;
  }

  late int _roundSummoned;

  void _setLevel(Monster monster) {
    dynamic newHealthValue =
        10; //need to put something outer than 0 or the standee will die immediately causing glitch
    if (type == MonsterType.boss) {
      newHealthValue = monster.type.levels[monster.level.value].boss!.health;
    } else if (type == MonsterType.elite) {
      newHealthValue = monster.type.levels[monster.level.value].elite!.health;
    } else if (type == MonsterType.normal) {
      newHealthValue = monster.type.levels[monster.level.value].normal!.health;
    }
    int? value = StatCalculator.calculateFormula(newHealthValue);
    if (value != null) {
      _maxHealth.value = value;
    } else {
      //handle edge case
      if (newHealthValue == "Hollowpact") {
        int value = 7;
        for (var item in getIt<GameState>().currentList) {
          if (item is Character && item.id == "Hollowpact") {
            value = item.characterClass
                .healthByLevel[item.characterState.level.value - 1];
            break;
          }
        }
        _maxHealth.value = value;
      }
      if (newHealthValue == "Incarnate") {
        int value = 36; //double Incarnates level 5 health
        for (var item in getIt<GameState>().currentList) {
          if (item is Character && item.id == "Incarnate") {
            value = item.characterClass
                    .healthByLevel[item.characterState.level.value - 1] *
                2;
            break;
          }
        }
        _maxHealth.value = value;
      }
    }
    _level.value = monster.level.value;
    _health.value = maxHealth.value;
  }

  @override
  String toString() {
    return '{'
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"standeeNr": $standeeNr, '
        '"move": $move, '
        '"attack": $attack, '
        '"range": $range, '
        '"name": "$name", '
        '"gfx": "$gfx", '
        '"roundSummoned": $roundSummoned, '
        '"type": ${type.index}, '
        '"chill": ${chill.value}, '
        '"conditions": ${conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${_conditionsAddedThisTurn.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${_conditionsAddedPreviousTurn.toList().toString()} '
        '}';
  }

  MonsterInstance.fromJson(Map<String, dynamic> json) {
    standeeNr = json["standeeNr"];
    _health.value = json["health"];
    _level.value = json["level"];
    _maxHealth.value = json["maxHealth"];
    name = json["name"];
    gfx = json["gfx"];
    _type = MonsterType.values[json["type"]];
    move = json["move"];
    attack = json["attack"];
    range = json["range"];
    if (json.containsKey("roundSummoned")) {
      _roundSummoned = json["roundSummoned"];
    } else {
      _roundSummoned = -1;
    }
    _chill.value = json["chill"];
    List<dynamic> condis = json["conditions"];
    for (int item in condis) {
      conditions.value.add(Condition.values[item]);
    }

    if (json.containsKey("conditionsAddedThisTurn")) {
      List<dynamic> condis2 = json["conditionsAddedThisTurn"];
      for (int item in condis2) {
        _conditionsAddedThisTurn.add(Condition.values[item]);
      }
    }
    if (json.containsKey("conditionsAddedPreviousTurn")) {
      List<dynamic> condis3 = json["conditionsAddedPreviousTurn"];
      for (int item in condis3) {
        _conditionsAddedPreviousTurn.add(Condition.values[item]);
      }
    }
  }
}
