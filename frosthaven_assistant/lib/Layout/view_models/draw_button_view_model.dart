import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_actions.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class DrawButtonViewModel {
  static const double _kWidthWithTotalRounds = 75.0;
  static const double _kWidthWithoutTotalRounds = 60.0;
  DrawButtonViewModel({GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;
  ValueListenable<int> get round => _gameState.round;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;

  // Derived state
  String get buttonText =>
      _gameState.roundState.value == RoundState.chooseInitiative
          ? "Draw"
          : " Next Round";

  String get roundText {
    final r = _gameState.round.value;
    final total = _gameState.totalRounds.value;
    if (total != r) return "$r($total)";
    return r.toString();
  }

  double get buttonWidth =>
      _gameState.totalRounds.value != _gameState.round.value
          ? _kWidthWithTotalRounds
          : _kWidthWithoutTotalRounds;

  /// Runs the draw/next-round action. Returns a blocked message if the action
  /// was blocked, or null if it succeeded.
  String? runAction() {
    final result = runDrawOrNextRoundAction(_gameState);
    return result.blockedMessage;
  }
}
