import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class CharacterHealthWidgetViewModel {
  CharacterHealthWidgetViewModel({GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final Settings _settings;

  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  bool get enableHealthWheel => _settings.enableHeathWheel.value;
  bool get frosthavenStyle => GameMethods.isFrosthavenStyle(null);
}
