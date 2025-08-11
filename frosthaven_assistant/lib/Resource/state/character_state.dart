part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class CharacterState extends FigureState {
  final _display = ValueNotifier<String>("");
  final _initiative = ValueNotifier<int>(0);
  final _xp = ValueNotifier<int>(0);
  final List<MonsterInstance> _summonList = [];

  late final ModifierDeck _modifierDeck;

  ValueListenable<String> get display => _display;
  ValueListenable<int> get initiative => _initiative;
  ValueListenable<int> get xp => _xp;
  BuiltList<MonsterInstance> get summonList => BuiltList.of(_summonList);
  ModifierDeck get modifierDeck => _modifierDeck;

  CharacterState(final String id) {
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
    for (var item in summons) {
      _summonList.add(MonsterInstance.fromJson(item));
    }

    final condis = json["conditions"];
    for (int item in condis) {
      conditions.value.add(Condition.values[item]);
    }

    if (json.containsKey("modifierDeck")) {
      final deck = json["modifierDeck"];
      _modifierDeck = ModifierDeck.fromJson(id, deck);
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

  setDisplay(_StateModifier _, String value) {
    _display.value = value;
  }

  setInitiative(_StateModifier _, int value) {
    _initiative.value = value;
  }

  setXp(_StateModifier _, int value) {
    _xp.value = value;
  }

  getMutableSummonList(_StateModifier _) {
    return _summonList;
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
        '"conditions": ${conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${conditionsAddedThisTurn.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${conditionsAddedPreviousTurn.toList().toString()} '
        '}';
  }
}
