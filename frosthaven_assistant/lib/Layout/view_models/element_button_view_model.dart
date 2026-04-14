import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/imbue_element_command.dart';
import 'package:frosthaven_assistant/Resource/commands/use_element_command.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class ElementButtonViewModel {
  ElementButtonViewModel(this.element, {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Elements element;
  final GameState _gameState;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  ValueListenable<bool> get darkMode => _settings.darkMode;

  double get userScalingBars => _settings.userScalingBars.value;

  // Derived state
  ElementState? get elementState => _gameState.elementState[element];

  /// Icon tint: black in light mode when element is inert, null otherwise.
  Color? get iconColor {
    if (!_settings.darkMode.value) {
      if (elementState == ElementState.inert) return Colors.black;
    }
    return null;
  }

  // Actions
  void imbue({bool half = false}) {
    _gameState.action(ImbueElementCommand(element, half));
  }

  /// Tap: use if active, imbue if inert.
  void tap() {
    final state = elementState;
    if (state == ElementState.half || state == ElementState.full) {
      _gameState.action(UseElementCommand(element));
    } else {
      _gameState.action(ImbueElementCommand(element, false));
    }
  }
}
