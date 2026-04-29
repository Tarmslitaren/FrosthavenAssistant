import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ConditionIconViewModel {
  ConditionIconViewModel({Settings? settings})
      : _settings = settings ?? getIt<Settings>();

  final Settings _settings;

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
    Iterable<Condition> addedPreviousTurn,
  ) {
    if (condition == Condition.bane && !addedThisTurn.contains(condition)) {
      return true;
    }
    if (addedPreviousTurn.contains(condition)) {
      if (!_settings.expireConditions.value) {
        if (condition == Condition.chill ||
            condition == Condition.stun ||
            condition == Condition.disarm ||
            condition == Condition.immobilize ||
            condition == Condition.invisible ||
            condition == Condition.strengthen ||
            condition == Condition.muddle ||
            condition == Condition.impair) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCharacterCondition(Condition condition) =>
      condition.name.contains("character");

  Color classColorFor(Condition condition) {
    if (!isCharacterCondition(condition)) return Colors.transparent;
    final characters = GameMethods.getCurrentCharacters();
    final match =
        characters.where((e) => e.characterClass.name == condition.getName());
    if (match.isEmpty) return Colors.transparent;
    return match.first.characterClass.color;
  }
}
