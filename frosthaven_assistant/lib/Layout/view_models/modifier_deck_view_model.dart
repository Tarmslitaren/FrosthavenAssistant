import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/game_event.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../menus/modifier_card_zoom.dart';
import '../menus/modifier_deck_menu.dart';

class ModifierDeckViewModel {
  ModifierDeckViewModel(
    this.name, {
    GameState? gameState,
    GameData? gameData,
    Settings? settings,
  })  : _gameState = gameState ?? getIt<GameState>(),
        _gameData = gameData ?? getIt<GameData>(),
        _settings = settings ?? getIt<Settings>();

  final String name;
  final GameState _gameState;
  final GameData _gameData;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  ValueListenable<Map<String, CampaignModel>> get modelData =>
      _gameData.modelData;

  // Derived state
  ModifierDeck get deck => GameMethods.getModifierDeck(name, _gameState);

  Character? get currentCharacter {
    final c = GameMethods.getCurrentCharacter();
    if (c != null && c.id == deck.name) return c;
    return null;
  }

  Color get currentCharacterColor =>
      currentCharacter != null ? Colors.black : Colors.transparent;

  String? get currentCharacterName => currentCharacter?.characterClass.name;

  bool initAnimationEnabled() {
    final event = _gameState.lastEvent.value;
    return event is ModifierCardDrawnEvent && event.deckName == name;
  }

  void drawCard() {
    _gameState.action(DrawModifierCardCommand(name, gameState: _gameState));
  }

  void openModifierMenu(BuildContext context) {
    openDialog(context, ModifierDeckMenu(name: deck.name));
  }

  void openZoom(BuildContext context) {
    if (deck.discardPileIsNotEmpty) {
      openDialog(context,
          ModifierCardZoom(name: name, card: deck.discardPileTop));
    }
  }
}
