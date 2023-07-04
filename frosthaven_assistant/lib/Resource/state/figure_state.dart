part of game_state;
class FigureState {

  ValueListenable<int> get health => _health;
  final _health = ValueNotifier<int>(0);
  setHealth(_StateModifier stateModifier, int value) {_health.value = value;}

  ValueListenable<int> get level => _level;
  final _level = ValueNotifier<int>(1);
  setFigureLevel(_StateModifier stateModifier, int value) {_level.value = value;}
  ValueListenable<int> get maxHealth => _maxHealth;
  final _maxHealth = ValueNotifier<int>(0);
  setMaxHealth(_StateModifier stateModifier, int value) {_maxHealth.value = value;}
  //? //needed for the times you wanna set hp yourself, for special reasons
  ValueListenable<int> get chill => _chill;
  final _chill = ValueNotifier<int>(0);
  setChill(_StateModifier stateModifier, int value) {_chill.value = value;}

  //TODO:  no valuenotifier for lists - make non mutable vrsion
  final conditions = ValueNotifier<List<Condition>>([]);

  BuiltSet<Condition> get conditionsAddedThisTurn => BuiltSet.of(_conditionsAddedThisTurn);
  final Set<Condition> _conditionsAddedThisTurn = {};
  Set<Condition> getMutableConditionsAddedThisTurn(_StateModifier stateModifier) {return _conditionsAddedThisTurn;}
  BuiltSet<Condition> get conditionsAddedPreviousTurn => BuiltSet.of(_conditionsAddedPreviousTurn);
  final Set<Condition> _conditionsAddedPreviousTurn = {};
  Set<Condition> getMutableConditionsAddedPreviousTurn(_StateModifier stateModifier) {return _conditionsAddedPreviousTurn;}
}
