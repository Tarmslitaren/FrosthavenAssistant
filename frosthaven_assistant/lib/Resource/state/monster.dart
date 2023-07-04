part of game_state;

class Monster extends ListItemData {
  Monster(String name, int level, this._isAlly) {
    id = name;
    _level.value = level;
    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys) {
      monsters.addAll(gameState.modelData.value[key]!.monsters);
    }
    for (String key in monsters.keys) {
      if (key == name) {
        type = monsters[key]!;
      }
    }

    GameMethods.addAbilityDeck(this);
  }
  late final MonsterModel type;


  BuiltList<MonsterInstance> get monsterInstances => BuiltList.of(_monsterInstances);
  getMutableMonsterInstancesList(_StateModifier stateModifier) {return _monsterInstances;}
  final List<MonsterInstance> _monsterInstances = [];

  ValueListenable<int> get level => _level;
  final _level = ValueNotifier<int>(0);

  bool get isAlly => _isAlly;
  bool _isAlly;

  //note: this is only used for the no standee tracking setting
  bool get isActive => _isActive;
  setActive(_StateModifier stateModifier, bool value) {_isActive = value;}
  bool _isActive = false;

  bool hasElites() {
    for (var instance in _monsterInstances) {
      if (instance.type == MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  //includes boss
  bool hasNormal() {
    for (var instance in _monsterInstances) {
      if (instance.type != MonsterType.elite) {
        return true;
      }
    }
    return false;
  }

  void setLevel(int level) {
    _level.value = level;
    for (var item in _monsterInstances) {
      item.setLevel(this);
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.index}, '
        '"isActive": $isActive, '
        '"type": "${type.name}", '
        '"monsterInstances": ${_monsterInstances.toString()}, '
        '"isAlly": $isAlly, '
        '"level": ${level.value} '
        '}';
  }

  Monster.fromJson(Map<String, dynamic> json) : _isAlly = false {
    id = json['id'];
    _turnState = TurnsState.values[json['turnState']];
    _level.value = json['level'];
    if (json.containsKey("isAlly")) {
      _isAlly = json['isAlly'];
    }
    if (json.containsKey("isActive")) {
      _isActive = json['isActive'];
    }
    String modelName = json['type'];

    GameState gameState = getIt<GameState>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameState.modelData.value.keys) {
      monsters.addAll(gameState.modelData.value[key]!.monsters);
    }
    for (var item in monsters.keys) {
      if (item == modelName) {
        type = monsters[item]!;
        break;
      }
    }

    List<dynamic> instanceList = json["monsterInstances"];

    _monsterInstances.clear();
    for (Map<String, dynamic> item in instanceList) {
      var instance = MonsterInstance.fromJson(item);
      _monsterInstances.add(instance);
    }
  }
}
