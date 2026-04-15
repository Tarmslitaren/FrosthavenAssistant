import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/game_event.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../menus/loot_cards_menu.dart';

class LootDeckViewModel {
  LootDeckViewModel(
      {GameState? gameState,
      GameData? gameData,
      Settings? settings})
      : _gameState = gameState ?? getIt<GameState>(),
        _gameData = gameData ?? getIt<GameData>(),
        _settings = settings ?? getIt<Settings>();

  final GameState _gameState;
  final GameData _gameData;
  final Settings _settings;

  // Notifiers the widget subscribes to
  ValueListenable<double> get userScalingBars => _settings.userScalingBars;
  ValueListenable<int> get commandIndex => _gameState.commandIndex;
  ValueListenable<int> get cardCount => _gameState.lootDeck.cardCount;
  ValueListenable<Map<String, CampaignModel>> get modelData =>
      _gameData.modelData;

  // Derived state
  LootDeck get lootDeck => _gameState.lootDeck;

  bool get shouldHide =>
      (lootDeck.drawPileIsEmpty && lootDeck.discardPileIsEmpty) ||
      _settings.hideLootDeck.value;

  Character? get currentCharacter => GameMethods.getCurrentCharacter();

  Color get currentCharacterColor =>
      currentCharacter != null ? Colors.black : Colors.transparent;

  String? get currentCharacterName => currentCharacter?.characterClass.name;

  bool initAnimationEnabled() {
    return _gameState.lastEvent.value is LootCardDrawnEvent;
  }

  void drawCard() {
    _gameState.action(DrawLootCardCommand(gameState: _gameState));
  }

  void openLootMenu(BuildContext context) {
    openDialog(context, const LootCardsMenu());
  }
}
