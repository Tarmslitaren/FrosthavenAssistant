part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api
class FigureState {
  //TODO:  no value notifier for lists - make non mutable version
  final conditions = ValueNotifier<List<Condition>>([]);

  final _level = ValueNotifier<int>(1);
  final _health = ValueNotifier<int>(0);
  final _maxHealth = ValueNotifier<int>(0);
  final _chill = ValueNotifier<int>(0);
  final _plague = ValueNotifier<int>(0);
  final Set<Condition> _conditionsAddedThisTurn = {};
  final Set<Condition> _conditionsAddedPreviousTurn = {};

  ValueListenable<int> get level => _level;
  ValueListenable<int> get health => _health;
  ValueListenable<int> get maxHealth => _maxHealth;
  ValueListenable<int> get chill => _chill;
  ValueListenable<int> get plague => _plague;
  BuiltSet<Condition> get conditionsAddedThisTurn =>
      BuiltSet.of(_conditionsAddedThisTurn);
  BuiltSet<Condition> get conditionsAddedPreviousTurn =>
      BuiltSet.of(_conditionsAddedPreviousTurn);

  setHealth(_StateModifier _, int value) {
    _health.value = value;
  }

  setFigureLevel(_StateModifier _, int value) {
    _level.value = value;
  }

  setMaxHealth(_StateModifier _, int value) {
    _maxHealth.value = value;
  }

  setChill(_StateModifier _, int value) {
    _chill.value = value;
  }

  setPlague(_StateModifier _, int value) {
    _plague.value = value;
  }

  Set<Condition> getMutableConditionsAddedThisTurn(_StateModifier _) {
    return _conditionsAddedThisTurn;
  }

  Set<Condition> getMutableConditionsAddedPreviousTurn(_StateModifier _) {
    return _conditionsAddedPreviousTurn;
  }
}
