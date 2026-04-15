import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../../Resource/enums.dart';
import '../../Resource/ui_utils.dart';
import '../menus/status_menu.dart';

class CharacterViewModel {
  CharacterViewModel(this.character,
      {GameState? gameState, Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _settings = settings ?? getIt<Settings>();

  final Character character;
  final GameState _gameState;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<int> get updateList => _gameState.updateList;
  ValueListenable<BuiltList<MonsterInstance>> get summonListNotifier =>
      character.characterState.summonListNotifier;

  // Derived state
  bool get isAlive => character.characterState.health.value != 0;
  bool get isTurnDone => character.turnState.value == TurnsState.done;
  bool get isCurrentTurn => character.turnState.value == TurnsState.current;
  bool get isChooseInitiative =>
      _gameState.roundState.value == RoundState.chooseInitiative;

  /// Whether the character card should render in full colour (not greyed out).
  bool get notGrayScale => isAlive && (!isTurnDone || isChooseInitiative);

  bool get showHealthWheel => _settings.enableHeathWheel.value;

  void openStatusMenu(BuildContext context) {
    openDialog(
        context,
        StatusMenu(
            figureId: character.id, characterId: character.id));
  }
}
