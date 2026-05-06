import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class BottomBarLevelWidgetViewModel {
  static const double _kFontSize = 14.0;
  static const double _kWhiteBlurSmall = 3.0;
  static const double _kWhiteBlurLarge = 8.0;
  BottomBarLevelWidgetViewModel({GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final Settings _settings;

  ValueListenable<String> get scenario => _gameState.scenario;
  ValueListenable<int> get level => _gameState.level;

  double get userScalingBars => _settings.userScalingBars.value;
  double get fontHeight => _kFontSize * userScalingBars;

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
    final fontH = _kFontSize * scaling;
    final shadow = textShadow(scaling);
    return TextStyle(
        color: darkMode ? Colors.white : Colors.black,
        overflow: TextOverflow.fade,
        fontSize: fontH,
        shadows: darkMode
            ? [shadow]
            : [
                Shadow(
                    offset: Offset(kShadowOffset * scaling, kShadowOffset * scaling),
                    blurRadius: _kWhiteBlurSmall * scaling,
                    color: Colors.white),
                Shadow(
                    offset: Offset(kShadowOffset * scaling, kShadowOffset * scaling),
                    blurRadius: _kWhiteBlurLarge * scaling,
                    color: Colors.white),
              ]);
  }

  int get trapValue => GameMethods.getTrapValue();
  int get hazardValue => GameMethods.getHazardValue();
  int get xpValue => GameMethods.getXPValue();
  int get coinValue => GameMethods.getCoinValue();
}
