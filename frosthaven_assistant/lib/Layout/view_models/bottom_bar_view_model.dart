import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class BottomBarViewModel {
  static const double _kDarkModeOpacity = 0.4;
  BottomBarViewModel({Settings? settings, GameState? gameState})
      : _settings = settings ?? getIt<Settings>(),
        _gameState = gameState ?? getIt<GameState>();

  final Settings _settings;
  final GameState _gameState;

  // Notifiers the widget subscribes to
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;
  ValueListenable<bool> get darkMode => _settings.darkMode;

  // Derived state
  bool get isDarkMode => _settings.darkMode.value;

  Color get backgroundColor =>
      isDarkMode ? Colors.black : Colors.transparent;

  double get backgroundOpacity => isDarkMode ? _kDarkModeOpacity : 1.0;

  String get backgroundImagePath => isDarkMode
      ? 'assets/images/psd/gloomhaven-bar.png'
      : 'assets/images/psd/frosthaven-bar.png';

  bool showModifierDeck(BuildContext context) =>
      modifiersFitOnBar(context) &&
      _settings.showAmdDeck.value &&
      _gameState.currentCampaign.value != "Buttons and Bugs";
}
