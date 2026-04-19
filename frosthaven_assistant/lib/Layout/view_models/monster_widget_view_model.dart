import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/commands/next_turn_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class MonsterWidgetViewModel {
  MonsterWidgetViewModel(this.monster, {GameState? gameState})
      : _gameState = gameState ?? getIt<GameState>();

  final Monster monster;
  final GameState _gameState;

  // Notifiers the widget subscribes to
  Listenable get updateList => _gameState.updateList;
  ValueListenable<BuiltList<MonsterInstance>> get monsterInstancesNotifier =>
      monster.monsterInstancesNotifier;

  // Derived state
  bool get specialDisabled =>
      GameMethods.isInactiveForRule(monster.type.name);

  bool get frosthavenStyle => GameMethods.isFrosthavenStyle(monster.type);

  bool get isActive => monster.isActive;

  TurnsState get turnState => monster.turnState.value;

  RoundState get roundState => _gameState.roundState.value;

  bool get isGrayScale =>
      !isActive ||
      specialDisabled ||
      (turnState == TurnsState.done && roundState != RoundState.chooseInitiative);

  bool get showTurnTap =>
      roundState == RoundState.playTurns &&
      (monster.monsterInstances.isNotEmpty || isActive) &&
      !specialDisabled;

  void endTurn() {
    _gameState.action(TurnDoneCommand(monster.id, gameState: _gameState));
  }
}
