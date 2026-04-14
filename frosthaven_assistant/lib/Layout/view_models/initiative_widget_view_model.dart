import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../CharacterWidget/character_widget_internal.dart';

class InitiativeWidgetViewModel {
  InitiativeWidgetViewModel(this.character,
      {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Character character;
  final GameState _gameState;
  final Settings _settings;

  // Notifier the widget subscribes to
  ValueListenable<int> get initiative => character.characterState.initiative;

  // Derived state
  RoundState get roundState => _gameState.roundState.value;

  bool get isChooseInitiative => roundState == RoundState.chooseInitiative;

  bool get isAlive => character.characterState.health.value > 0;

  bool get frosthavenStyle => GameMethods.isFrosthavenStyle(null);

  String get fontFamily => frosthavenStyle ? 'GermaniaOne' : 'Pirata';

  bool get softNumpadInput => _settings.softNumpadInput.value;

  TextInputType get keyboardInputType =>
      softNumpadInput ? TextInputType.none : TextInputType.number;

  /// Whether the initiative value should be hidden (received from another device)
  bool get isSecret =>
      (_settings.server.value ||
          _settings.client.value == ClientState.connected) &&
      !CharacterWidgetInternal.localCharacterInitChanges
          .contains(character.id);

  String initiativeDisplayText(int initiative) {
    if (character.characterState.health.value > 0 && initiative > 0) {
      return initiative.toString();
    }
    return "";
  }
}
