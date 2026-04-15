part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Monster extends ListItemData {
  Monster(String name, int level, this._isAlly, {GameData? gameData}) {
    id = name;
    _level.value = level;
    final gd = gameData ?? getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gd.modelData.value.keys) {
      monsters.addAll(gd.modelData.value[key]!.monsters);
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
  final _monsterInstancesNotifier =
      ValueNotifier<BuiltList<MonsterInstance>>(BuiltList.of([]));
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
  ValueListenable<BuiltList<MonsterInstance>> get monsterInstancesNotifier =>
      _monsterInstancesNotifier;

  void _notifyMonsterInstances() {
    _monsterInstancesNotifier.value = BuiltList.of(_monsterInstances);
  }

  /// Public guarded notify — allows commands and part-file methods to fire
  /// the notifier at the correct time (e.g. after a 600 ms death animation).
  void notifyMonsterInstances(_StateModifier _) {
    _notifyMonsterInstances();
  }

  Monster.fromJson(Map<String, dynamic> json, {GameData? gameData})
      : _isAlly = false {
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

    final gd = gameData ?? getIt<GameData>();
    Map<String, MonsterModel> monsters = {};
    for (String key in gd.modelData.value.keys) {
      monsters.addAll(gd.modelData.value[key]!.monsters);
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
    _notifyMonsterInstances();
  }

  void setMonsterInstances(_StateModifier _, List<MonsterInstance> instances) {
    _monsterInstances.clear();
    _monsterInstances.addAll(instances);
  }

  void clearMonsterInstances(_StateModifier _) {
    _monsterInstances.clear();
  }

  void sortMonsterInstances(_StateModifier s) {
    RoundMethods.sortMonsterInstances(s, _monsterInstances);
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

  void _addAbilityDeck({GameState? gameState}) {
    final gs = gameState ?? getIt<GameState>();
    for (MonsterAbilityState deck in gs.currentAbilityDecks) {
      if (deck.name == type.deck) {
        return;
      }
    }
    gs._currentAbilityDecks.add(MonsterAbilityState(type.deck));
  }
}
