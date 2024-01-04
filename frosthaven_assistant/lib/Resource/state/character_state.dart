part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class CharacterState extends FigureState {
  CharacterState();

  ValueListenable<String> get display => _display;
  setDisplay(_StateModifier stateModifier, String value) {_display.value = value;}
  final _display = ValueNotifier<String>("");

  ValueListenable<int> get initiative => _initiative;
  setInitiative(_StateModifier stateModifier, int value) {_initiative.value = value;}
  final _initiative = ValueNotifier<int>(0);

  ValueListenable<int> get xp => _xp;
  setXp(_StateModifier stateModifier, int value) {_xp.value = value;}
  final _xp = ValueNotifier<int>(0);

  BuiltList<MonsterInstance> get summonList => BuiltList.of(_summonList);
  getMutableSummonList(_StateModifier stateModifier) {return _summonList;}
  final List<MonsterInstance> _summonList = [];

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
        '"summonList": ${_summonList.toString()}, '
        '"conditions": ${conditions.value.toString()}, '
        '"conditionsAddedThisTurn": ${conditionsAddedThisTurn.toList().toString()}, '
        '"conditionsAddedPreviousTurn": ${conditionsAddedPreviousTurn.toList().toString()} '
        '}';
  }

  CharacterState.fromJson(Map<String, dynamic> json) {
    _initiative.value = json['initiative'];
    _xp.value = json['xp'];
    _chill.value = json['chill'];
    _health.value = json["health"];
    _level.value = json["level"];
    _maxHealth.value = json["maxHealth"];
    _display.value = json['display'];

    List<dynamic> summons = json["summonList"];
    for (var item in summons) {
      _summonList.add(MonsterInstance.fromJson(item));
    }

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
