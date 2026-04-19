part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class Monster extends ListItemData {
  Monster(String name, int level, this._isAlly, {GameData? gameData})
      : type = _findType(name, gameData) {
    id = name;
    _level.value = level;
    _addAbilityDeck();
  }

  static MonsterModel _findType(String name, GameData? gameData) {
    final gd = gameData ?? getIt<GameData>();
    for (final key in gd.modelData.value.keys) {
      final campaign = gd.modelData.value[key];
      if (campaign == null) continue;
      if (campaign.monsters.containsKey(name)) {
        final model = campaign.monsters[name];
        if (model != null) return model;
      }
    }
    throw StateError('Monster model not found: $name');
  }

  MonsterModel type;
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
      : _isAlly = false,
        type = _findType(json['type'] as String, gameData) {
    id = json['id'];
    final turnStateIdx = json['turnState'] as int?;
    if (turnStateIdx != null &&
        turnStateIdx >= 0 &&
        turnStateIdx < TurnsState.values.length) {
      _turnState.value = TurnsState.values[turnStateIdx];
    }
    _level.value = json['level'];
    if (json.containsKey("isAlly")) {
      _isAlly = json['isAlly'];
    }
    if (json.containsKey("isActive")) {
      _isActive = json['isActive'];
    }

    List<Object?> instanceList = json["monsterInstances"] as List<Object?>;

    _monsterInstances.clear();
    for (Map<String, dynamic> item in instanceList.cast<Map<String, dynamic>>()) {
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

  /// Updates all mutable fields in-place from [json], firing notifiers so
  /// subscribed widgets rebuild automatically.
  void updateFromJson(Map<String, dynamic> json) {
    final turnStateIdx = json['turnState'] as int?;
    if (turnStateIdx != null &&
        turnStateIdx >= 0 &&
        turnStateIdx < TurnsState.values.length) {
      _turnState.value = TurnsState.values[turnStateIdx];
    }
    _level.value = json['level'] as int;
    if (json.containsKey("isAlly")) {
      _isAlly = json['isAlly'] as bool;
    }
    if (json.containsKey("isActive")) {
      _isActive = json['isActive'] as bool;
    }

    _monsterInstances.clear();
    for (Map<String, dynamic> item in json["monsterInstances"] as List) {
      _monsterInstances.add(MonsterInstance.fromJson(item));
    }

    // Backwards-compat: set isActive when instances exist but version flag absent.
    if (_monsterInstances.isNotEmpty && !_isActive) {
      if (!json.containsKey("v")) {
        _isActive = true;
      }
    }
    if (json.containsKey("v")) {
      _version = json['v'] as int;
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

  void setActive(_StateModifier _, bool value) {
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
  Map<String, dynamic> toJson() => {
        'id': id,
        'turnState': turnState.value.index,
        'isActive': isActive,
        'type': type.name,
        'monsterInstances': _monsterInstances.map((m) => m.toJson()).toList(),
        'isAlly': isAlly,
        'v': _version,
        'level': level.value,
      };

  @override
  String toString() => json.encode(toJson());

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
