import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/campaign.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../menus/loot_cards_menu.dart';

class LootDeckViewModel {
  LootDeckViewModel(
      {GameState? gameState,
      GameData? gameData,
      Settings? settings,
      Communication? communication})
      : _gameState = gameState ?? getIt<GameState>(),
        _gameData = gameData ?? getIt<GameData>(),
        _settings = settings ?? getIt<Settings>(),
        _communication = communication ?? getIt<Communication>();

  final GameState _gameState;
  final GameData _gameData;
  final Settings _settings;
  final Communication _communication;

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
    if (_settings.client.value == ClientState.connected) {
      final oldState = GameState(communication: _communication);
      const int offset = 1;
      final saveStatesLength = _gameState.gameSaveStates.length;
      if (saveStatesLength <= offset) {
        return false;
      }
      final oldSave = _gameState.gameSaveStates[saveStatesLength - offset];
      if (oldSave != null) {
        oldState.loadFromData(oldSave.getState());
        if (oldState.lootDeck.discardPileSize ==
            _gameState.lootDeck.discardPileSize - 1) {
          return true;
        }
      }
    }

    final commandIndex = _gameState.commandIndex.value;
    final commandDescriptions = _gameState.commandDescriptions;
    if (_settings.server.value && commandIndex >= 0) {
      if (commandDescriptions.length > commandIndex) {
        if (commandDescriptions[commandIndex].contains("Draw loot card")) {
          return true;
        }
      }
    }
    return false;
  }

  void drawCard() {
    _gameState.action(DrawLootCardCommand(gameState: _gameState));
  }

  void openLootMenu(BuildContext context) {
    openDialog(context, const LootCardsMenu());
  }
}
