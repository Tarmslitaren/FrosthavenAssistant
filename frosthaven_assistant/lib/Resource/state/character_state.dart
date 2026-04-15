part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class CharacterState extends FigureState {
  final _display = ValueNotifier<String>("");
  final List<bool> _perkList = List.filled(18, false);
  final _useFHPerks = ValueNotifier<bool>(false);

  final _initiative = ValueNotifier<int>(0);
  final _xp = ValueNotifier<int>(0);
  final List<MonsterInstance> _summonList = [];
  final _summonListNotifier =
      ValueNotifier<BuiltList<MonsterInstance>>(BuiltList.of([]));
  late final ModifierDeck _modifierDeck;

  ValueListenable<String> get display => _display;
  ValueListenable<int> get initiative => _initiative;
  ValueListenable<int> get xp => _xp;
  BuiltList<MonsterInstance> get summonList => BuiltList.of(_summonList);
  ValueListenable<BuiltList<MonsterInstance>> get summonListNotifier =>
      _summonListNotifier;
  ModifierDeck get modifierDeck => _modifierDeck;

  void _notifySummonList() {
    _summonListNotifier.value = BuiltList.of(_summonList);
  }

  /// Public guarded notify — allows commands to fire the notifier at the
  /// correct time (e.g. after a 600 ms death animation).
  void notifySummonList(_StateModifier _) {
    _notifySummonList();
  }

  BuiltList<bool> get perkList => BuiltList.of(_perkList);
  ValueListenable<bool> get useFHPerks => _useFHPerks;

  CharacterState(final String id) {
    _modifierDeck = ModifierDeck(id);
  }

  CharacterState.fromSave(final String id, Map<String, dynamic> json) {
    _level.value = json["level"];
    _display.value = json['display'];
    if (json.containsKey("useFHPerks")) {
      _useFHPerks.value = json["useFHPerks"];
    }
    if (json.containsKey("perkList")) {
      final perks = json["perkList"];
      int i = 0;
      for (bool item in perks) {
        _perkList[i] = item;
        i++;
      }
    }
    _modifierDeck = ModifierDeck(id);
  }

  CharacterState.fromJson(final String id, Map<String, dynamic> json) {
    _initiative.value = json['initiative'];
    _xp.value = json['xp'];
    _chill.value = json['chill'];
    _health.value = json["health"];
    _level.value = json["level"];
    _maxHealth.value = json["maxHealth"];
    _display.value = json['display'];

    final summons = json["summonList"];
    for (final item in summons) {
      _summonList.add(MonsterInstance.fromJson(item));
    }
    _notifySummonList();

    //todo: automate check json.containsKey for everything: the nr of update bugs...
    if (json.containsKey("perkList")) {
      final perks = json["perkList"];
      int i = 0;
      for (bool item in perks) {
        _perkList[i] = item;
        i++;
      }
    }
    if (json.containsKey("useFHPerks")) {
      _useFHPerks.value = json["useFHPerks"];
    }

    final condis = json["conditions"];
    for (int item in condis) {
      _conditions.value.add(Condition.values[item]);
    }

    if (json.containsKey("modifierDeck")) {
      final deck = json["modifierDeck"];
      _modifierDeck = ModifierDeck.fromJson(id, deck);
    } else {
      //needs to be initialized first time
      _modifierDeck = ModifierDeck(id);
    }

    if (json.containsKey("conditionsAddedThisTurn")) {
      final condis2 = json["conditionsAddedThisTurn"];
      for (int item in condis2) {
        _conditionsAddedThisTurn.add(Condition.values[item]);
      }
    }
    if (json.containsKey("conditionsAddedPreviousTurn")) {
      final condis3 = json["conditionsAddedPreviousTurn"];
      for (int item in condis3) {
        _conditionsAddedPreviousTurn.add(Condition.values[item]);
      }
    }
  }

  /// Updates all fields in-place from [json], firing [ValueNotifier] listeners
  /// so subscribed widgets rebuild automatically. Preserves object identity so
  /// existing [ValueListenableBuilder] subscriptions remain valid.
  void updateFromJson(String id, Map<String, dynamic> json) {
    _initiative.value = json['initiative'] as int;
    _xp.value = json['xp'] as int;
    _chill.value = json['chill'] as int;
    _health.value = json["health"] as int;
    _level.value = json["level"] as int;
    _maxHealth.value = json["maxHealth"] as int;
    _display.value = json['display'] as String;
    _plague.value = 0; // not serialised — reset to match fromJson behaviour

    _summonList.clear();
    for (final item in json["summonList"]) {
      _summonList.add(MonsterInstance.fromJson(item as Map<String, dynamic>));
    }
    _notifySummonList();

    for (int i = 0; i < _perkList.length; i++) {
      _perkList[i] = false;
    }
    if (json.containsKey("perkList")) {
      int i = 0;
      for (bool item in json["perkList"]) {
        _perkList[i] = item;
        i++;
      }
    }
    _useFHPerks.value =
        json.containsKey("useFHPerks") ? json["useFHPerks"] as bool : false;

    // Assign a new list instance so the ValueNotifier fires its listeners.
    final newConditions = <Condition>[];
    for (int item in json["conditions"]) {
      newConditions.add(Condition.values[item]);
    }
    _conditions.value = newConditions;

    if (json.containsKey("modifierDeck")) {
      _modifierDeck
          .updateFromJson(json["modifierDeck"] as Map<String, dynamic>);
    } else {
      _modifierDeck.resetToDefault();
    }

    _conditionsAddedThisTurn.clear();
    if (json.containsKey("conditionsAddedThisTurn")) {
      for (int item in json["conditionsAddedThisTurn"]) {
        _conditionsAddedThisTurn.add(Condition.values[item]);
      }
    }
    _conditionsAddedPreviousTurn.clear();
    if (json.containsKey("conditionsAddedPreviousTurn")) {
      for (int item in json["conditionsAddedPreviousTurn"]) {
        _conditionsAddedPreviousTurn.add(Condition.values[item]);
      }
    }
  }

  flipPerk(_StateModifier _, int index) {
    _perkList[index] = !_perkList[index];
  }

  setDisplay(_StateModifier _, String value) {
    _display.value = value;
  }

  setInitiative(_StateModifier _, int value) {
    _initiative.value = value;
  }

  setXp(_StateModifier _, int value) {
    _xp.value = max(value, 0);
  }

  void addSummon(_StateModifier _, MonsterInstance summon) {
    _summonList.add(summon);
    _notifySummonList();
  }

  /// Removes [summon] from the list but does NOT fire the notifier.
  /// The caller is responsible for calling [notifySummonList] at the
  /// appropriate time (e.g. after a 600 ms death animation).
  void removeSummon(_StateModifier _, MonsterInstance summon) {
    _summonList.remove(summon);
  }

  String toSave() {
    return '{'
        '"level": ${level.value}, '
        '"useFHPerks": ${jsonEncode(useFHPerks.value)}, '
        '"display": ${jsonEncode(display.value)}, '
        '"perkList": ${_perkList.toString()} '
        '}';
  }

  @override
  String toString() {
    return '{'
        '"initiative": ${initiative.value}, '
        '"health": ${health.value}, '
        '"maxHealth": ${maxHealth.value}, '
        '"level": ${level.value}, '
        '"xp": ${xp.value}, '
        '"chill": ${chill.value}, '
        '"display": ${jsonEncode(display.value)}, '
        '"modifierDeck": ${_modifierDeck.toString()}, '
        '"summonList": ${_summonList.toString()}, '
        '"useFHPerks": ${jsonEncode(useFHPerks.value)}, '
        '"perkList": ${_perkList.toString()}, '
        '"conditions": ${_conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${conditionsAddedThisTurn.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${conditionsAddedPreviousTurn.toList().toString()} '
        '}';
  }
}
