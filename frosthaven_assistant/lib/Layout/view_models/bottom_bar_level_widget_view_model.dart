import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class BottomBarLevelWidgetViewModel {
  BottomBarLevelWidgetViewModel({GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final Settings _settings;

  ValueListenable<String> get scenario => _gameState.scenario;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  double get userScalingBars => _settings.userScalingBars.value;
  double get fontHeight => 14 * userScalingBars;

  String get formattedScenarioName {
    final s = _gameState.scenario.value;
    if (_gameState.currentCampaign.value == "Solo") {
      if (s.contains(':')) {
        return s.split(':')[1];
      }
    }
    return s;
  }

  TextStyle textStyle(double scaling) {
    final darkMode = _settings.darkMode.value;
    final fontH = 14 * scaling;
    final shadow = Shadow(
      offset: Offset(1 * scaling, 1 * scaling),
      color: Colors.black87,
      blurRadius: 1 * scaling,
    );
    return TextStyle(
        color: darkMode ? Colors.white : Colors.black,
        overflow: TextOverflow.fade,
        fontSize: fontH,
        shadows: darkMode
            ? [shadow]
            : [
                Shadow(
                    offset: Offset(1.0 * scaling, 1.0 * scaling),
                    blurRadius: 3.0 * scaling,
                    color: Colors.white),
                Shadow(
                    offset: Offset(1.0 * scaling, 1.0 * scaling),
                    blurRadius: 8.0 * scaling,
                    color: Colors.white),
              ]);
  }

  int get level => _gameState.level.value;
  int get trapValue => GameMethods.getTrapValue();
  int get hazardValue => GameMethods.getHazardValue();
  int get xpValue => GameMethods.getXPValue();
  int get coinValue => GameMethods.getCoinValue();
}
