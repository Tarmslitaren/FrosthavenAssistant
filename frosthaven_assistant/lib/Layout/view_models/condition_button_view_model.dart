import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ConditionButtonViewModel {
  ConditionButtonViewModel({
    required this.condition,
    required this.figureId,
    required this.ownerId,
    required this.immunities,
    GameState? gameState,
    Settings? settings,
  })  : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Condition condition;
  final String figureId;
  final String? ownerId;
  final List<String> immunities;
  final GameState _gameState;
  final Settings _settings;

  FigureState? get figure => GameMethods.getFigure(ownerId, figureId);

  ListItemData get owner =>
      _gameState.currentList.firstWhereOrNull((item) => item.id == ownerId) ??
      ListItemData();

  bool get isActive =>
      figure?.conditions.value.contains(condition) ?? false;

  bool get isCharacter => condition.name.contains("character");

  Color get classColor {
    if (!isCharacter) return Colors.transparent;
    final characters = GameMethods.getCurrentCharacters();
    final matches =
        characters.where((e) => e.characterClass.name == condition.getName());
    if (matches.isEmpty) return Colors.transparent;
    return matches.first.characterClass.color;
  }

  String get imagePath {
    final suffix = GameMethods.isFrosthavenStyle(null) ? "_fh" : "";
    if (isCharacter) {
      return "assets/images/class-icons/${condition.getName()}.png";
    }
    if (suffix.isNotEmpty && hasGHVersion(condition.name)) {
      return "assets/images/abilities/${condition.getName()}$suffix.png";
    }
    return "assets/images/abilities/${condition.name}.png";
  }

  bool get enabled {
    for (final item in immunities) {
      final immunity = item.substring(1, item.length - 1);
      if (condition.name.contains(immunity)) return false;
      if (immunity == "poison" && condition == Condition.infect) return false;
      if (immunity == "wound" && condition == Condition.rupture) return false;
    }
    return true;
  }

  bool get isDarkMode => _settings.darkMode.value;

  ValueListenable<bool> get darkModeListenable => _settings.darkMode;
}
