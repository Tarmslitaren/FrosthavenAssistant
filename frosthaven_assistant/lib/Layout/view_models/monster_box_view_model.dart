import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class MonsterBoxViewModel {
  static const Map<int, Color> _kBnBColors = {
    1: Colors.green,
    2: Colors.blue,
    3: Colors.purple,
    4: Colors.red,
  };

  MonsterBoxViewModel(
      this.data, {
      required this.ownerId,
      GameState? gameState,
      Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final MonsterInstance data;
  final String? ownerId;
  final GameState _gameState;
  final Settings _settings;

  /// Standee color based on monster type and campaign rules.
  Color get color {
    Color c = Colors.white;
    if (data.type == MonsterType.elite) c = Colors.yellow;
    if (data.type == MonsterType.boss) c = Colors.red;

    if (_gameState.currentCampaign.value == "Buttons and Bugs") {
      c = _kBnBColors[data.standeeNr] ?? c;
    }
    return c;
  }

  /// Returns the owner's id when it differs from the standee's monster name
  /// (i.e. the standee belongs to a character summon).
  String? get characterId => ownerId != data.name ? ownerId : null;

  /// The monster group id this standee belongs to, or null if not found.
  String? get monsterId {
    for (var item in _gameState.currentList) {
      if (item is Monster && item.id == data.name) {
        return item.id;
      }
    }
    return null;
  }

  bool get isAlive =>
      data.health.value > 0 ||
      GameMethods.summonDoesNotDie(ownerId, data.name);

  bool get ownerIsCurrent {
    for (var item in _gameState.currentList) {
      if (item.id == ownerId) {
        return item.turnState.value != TurnsState.done;
      }
    }
    return true;
  }

  bool get isSummonedThisTurn =>
      data.roundSummoned == _gameState.round.value && ownerIsCurrent;

  bool get useHealthWheel => _settings.enableHeathWheel.value;

  /// Returns the owner ListItemData for building condition icons.
  ListItemData? get ownerItem {
    for (var item in _gameState.currentList) {
      if (item.id == ownerId) return item;
    }
    return null;
  }
}
