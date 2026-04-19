import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:flutter/material.dart';

class ConditionIconViewModel {
  ConditionIconViewModel(
      {GameState? gameState, Settings? settings, Communication? communication})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>(),
        _communication = communication ?? getIt<Communication>();

  final GameState _gameState;
  final Settings _settings;
  final Communication _communication;

  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  GameState? getOldState() {
    final gs = _gameState;
    final oldState = GameState(communication: _communication);
    const offset = 1;
    if (gs.gameSaveStates.length <= offset ||
        gs.gameSaveStates[gs.gameSaveStates.length - offset] == null) {
      return null;
    }
    final oldSave =
        gs.gameSaveStates[gs.gameSaveStates.length - offset]!.getState(); // ignore: avoid-non-null-assertion
    oldState.loadFromData(oldSave);
    return oldState;
  }

  int? getTurnChanged(GameState oldState, GameState currentState) {
    if (oldState.round.value == currentState.round.value &&
        oldState.roundState.value == currentState.roundState.value &&
        oldState.currentList.length == currentState.currentList.length) {
      for (int i = 0; i < oldState.currentList.length; i++) {
        final oldItem = oldState.currentList[i];
        final currentItem = currentState.currentList[i];
        if (oldItem.id == currentItem.id) {
          if (oldItem.turnState.value != currentItem.turnState.value) {
            return i;
          }
        }
      }
    }
    return null;
  }

  /// Returns true if the given condition icon should trigger its shake animation
  /// based on the transition from [oldState] to the current game state.
  bool shouldTriggerAnimation({
    required Condition condition,
    required ListItemData owner,
    required FigureState figure,
    required GameState oldState,
  }) {
    final currentState = _gameState;
    final int? turnIndex = getTurnChanged(oldState, currentState);

    int healthChangedValue = 0;
    String changeHealthId = '';

    if (oldState.round.value == currentState.round.value &&
        oldState.roundState.value == currentState.roundState.value &&
        oldState.currentList.length == currentState.currentList.length) {
      for (int i = 0; i < oldState.currentList.length; i++) {
        final oldItem = oldState.currentList[i];
        final currentItem = currentState.currentList[i];
        if (oldItem.id == currentItem.id) {
          if (oldItem is Character) {
            final diff = (currentItem as Character).characterState.health.value -
                oldItem.characterState.health.value;
            if (diff != 0) {
              healthChangedValue = diff;
              changeHealthId = oldItem.id;
              break;
            }
          } else if (oldItem is Monster) {
            final newMonster = currentItem as Monster;
            if (oldItem.monsterInstances.length ==
                newMonster.monsterInstances.length) {
              for (int j = 0; j < oldItem.monsterInstances.length; j++) {
                final old = oldItem.monsterInstances[j];
                final current = newMonster.monsterInstances[j];
                if (old.getId() == current.getId()) {
                  final diff = current.health.value - old.health.value;
                  if (diff != 0) {
                    healthChangedValue = diff;
                    changeHealthId = old.getId();
                    break;
                  }
                }
              }
              if (healthChangedValue != 0) break;
            }
          }
        }
      }
    }

    if (turnIndex != null) {
      for (var item in currentState.currentList) {
        if (item.id == owner.id &&
            item.turnState.value == TurnsState.current) {
          if (condition == Condition.regenerate ||
              condition == Condition.wound ||
              condition == Condition.wound2) {
            return true;
          }
        }
      }

      if (currentState.currentList[turnIndex].turnState.value ==
              TurnsState.done &&
          currentState.currentList[turnIndex].id == owner.id) {
        if (condition == Condition.bane &&
            !figure.conditionsAddedThisTurn.contains(condition)) {
          return true;
        }

        if (figure.conditionsAddedPreviousTurn.contains(condition)) {
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
      }
    }

    if (healthChangedValue != 0) {
      final isOwner = changeHealthId == owner.id ||
          (figure is MonsterInstance &&
              figure.getId() == changeHealthId);
      if (isOwner) {
        if (healthChangedValue < 0) {
          if (condition.name.contains("poison") ||
              condition == Condition.regenerate ||
              condition == Condition.ward ||
              condition == Condition.shield ||
              condition == Condition.retaliate ||
              condition == Condition.brittle) {
            return true;
          }
        } else {
          if (condition == Condition.rupture ||
              condition == Condition.wound ||
              condition == Condition.bane ||
              condition.name.contains("poison") ||
              condition == Condition.infect ||
              condition == Condition.brittle) {
            return true;
          }
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
    final match = characters.where(
        (e) => e.characterClass.name == condition.getName());
    if (match.isEmpty) return Colors.transparent;
    return match.first.characterClass.color;
  }
}
