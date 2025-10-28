part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Monster extends ListItemData {
  Monster(String name, int level, this._isAlly) {
    id = name;
    _level.value = level;
    GameData gameData = getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameData.modelData.value.keys) {
      monsters.addAll(gameData.modelData.value[key]!.monsters);
    }
    for (String key in monsters.keys) {
      if (key == name) {
        type = monsters[key]!;
      }
    }

    _addAbilityDeck();
  }
  late final MonsterModel type;
  final List<MonsterInstance> _monsterInstances = [];
  final _level = ValueNotifier<int>(0);
  bool _isAlly;
  bool _isActive = false;
  int _version = 0;

  ValueListenable<int> get level => _level;
  bool get isAlly => _isAlly;

  //note: this is only used for the no standee tracking setting
  bool get isActive => _isActive;

  BuiltList<MonsterInstance> get monsterInstances =>
      BuiltList.of(_monsterInstances);

  Monster.fromJson(Map<String, dynamic> json) : _isAlly = false {
    id = json['id'];
    _turnState.value = TurnsState.values[json['turnState']];
    _level.value = json['level'];
    if (json.containsKey("isAlly")) {
      _isAlly = json['isAlly'];
    }
    if (json.containsKey("isActive")) {
      _isActive = json['isActive'];
    }
    String modelName = json['type'];

    GameData gameData = getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gameData.modelData.value.keys) {
      monsters.addAll(gameData.modelData.value[key]!.monsters);
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

    //fixing update issue, when _isActive is repurposed to work even with standees
    if (_monsterInstances.isNotEmpty && !_isActive) {
      if (!json.containsKey("v")) {
        _isActive = true;
      }
    }
    if (json.containsKey("v")) {
      _version = json['v'];
    }
  }

  getMutableMonsterInstancesList(_StateModifier _) {
    return _monsterInstances;
  }

  setActive(_StateModifier _, bool value) {
    _isActive = value;
  }

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

  void setLevel(_StateModifier _, int level) {
    _level.value = level;
    for (var item in _monsterInstances) {
      item._setLevel(this);
    }
  }

  @override
  String toString() {
    return '{'
        '"id": "$id", '
        '"turnState": ${turnState.value.index}, '
        '"isActive": $isActive, '
        '"type": "${type.name}", '
        '"monsterInstances": ${_monsterInstances.toString()}, '
        '"isAlly": $isAlly, '
        '"v": $_version, '
        '"level": ${level.value} '
        '}';
  }

  void _addAbilityDeck() {
    final GameState gameState = getIt<GameState>();
    for (MonsterAbilityState deck in gameState.currentAbilityDecks) {
      if (deck.name == type.deck) {
        return;
      }
    }
    gameState._currentAbilityDecks.add(MonsterAbilityState(type.deck));
  }
}
