import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ConditionIconViewModel {
  ConditionIconViewModel({Settings? settings, GameState? gameState})
      : _settings = settings ?? getIt<Settings>(),
        _gameState = gameState ?? getIt<GameState>();

  final Settings _settings;
  final GameState _gameState;
  GameState get gameState => _gameState;

  bool shouldAnimateOnDamage(Condition condition) =>
      condition.name.contains("poison") ||
      condition == Condition.regenerate ||
      condition == Condition.ward ||
      condition == Condition.shield ||
      condition == Condition.retaliate ||
      condition == Condition.brittle;

  bool shouldAnimateOnHeal(Condition condition) =>
      condition == Condition.rupture ||
      condition == Condition.wound ||
      condition == Condition.bane ||
      condition.name.contains("poison") ||
      condition == Condition.infect ||
      condition == Condition.brittle;

  bool shouldAnimateOnTurnStart(Condition condition) =>
      condition == Condition.regenerate ||
      condition == Condition.wound ||
      condition == Condition.wound2;

  bool shouldAnimateOnTurnEnd(
    Condition condition,
    Iterable<Condition> addedThisTurn,
  ) {
    if (addedThisTurn.contains(condition)) return false;
    if (condition == Condition.bane) return true;
    return !_settings.expireConditions.value && GameMethods.canExpire(condition);
  }

  bool isCharacterCondition(Condition condition) =>
      condition.name.contains("character");

  Color classColorFor(Condition condition) {
    if (!isCharacterCondition(condition)) return Colors.transparent;
    final characters = GameMethods.getCurrentCharacters(gameState: _gameState);
    final match =
        characters.where((e) => e.characterClass.name == condition.getName());
    if (match.isEmpty) return Colors.transparent;
    return match.first.characterClass.color;
  }
}
