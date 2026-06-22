import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/widgets/scrollable_menu_card.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

import '../../../services/service_locator.dart';
import 'coin_rows_section.dart';
import 'herb_section.dart';
import 'loot_card_row.dart';
import 'loot_type_header.dart';
import 'material_section.dart';

// coin pool: "1" = 12 cards (4 rows of 3), "2" = 6 cards (2 rows of 3), "3" = 2 cards
const int _kCoin1Rows = 4;
const int _kCoinRowSize = 3;
const int _kCoin2Start = _kCoinRowSize * _kCoin1Rows;
const int _kCoin2Rows = 2;
const int _kCoin3Start = _kCoin2Start + _kCoinRowSize * _kCoin2Rows;
const int _kCoin3Count = 2;

class LootCardEnhancementMenu extends StatelessWidget {
  const LootCardEnhancementMenu({super.key, this.gameState});

  final GameState? gameState;

  GameState get _gameState => gameState ?? getIt<GameState>();

  LootCard? _getCard(String type, int index) {
    if (type == "lumber") return _gameState.lootDeck.lumberPool[index];
    if (type == "hide") return _gameState.lootDeck.hidePool[index];
    if (type == "metal") return _gameState.lootDeck.metalPool[index];
    if (type == "arrowvine") return _gameState.lootDeck.arrowvinePool[index];
    if (type == "axenut") return _gameState.lootDeck.axenutPool[index];
    if (type == "corpsecap") return _gameState.lootDeck.corpsecapPool[index];
    if (type == "flamefruit") return _gameState.lootDeck.flamefruitPool[index];
    if (type == "rockroot") return _gameState.lootDeck.rockrootPool[index];
    if (type == "snowthistle") {
      return _gameState.lootDeck.snowthistlePool[index];
    }
    if (type == "coin") return _gameState.lootDeck.coinPool[index];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableMenuCard(
      maxWidth: kMenuNarrowWidth,
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.lootCardEnhancements, style: kTitleStyle),
          MaterialSection(
            type: "hide",
            gameState: _gameState,
            getCard: _getCard,
          ),
          MaterialSection(
            type: "lumber",
            gameState: _gameState,
            getCard: _getCard,
          ),
          MaterialSection(
            type: "metal",
            gameState: _gameState,
            getCard: _getCard,
          ),
          HerbSection(
            type: "arrowvine",
            gameState: _gameState,
            getCard: _getCard,
          ),
          HerbSection(type: "axenut", gameState: _gameState, getCard: _getCard),
          HerbSection(
            type: "corpsecap",
            gameState: _gameState,
            getCard: _getCard,
          ),
          HerbSection(
            type: "flamefruit",
            gameState: _gameState,
            getCard: _getCard,
          ),
          HerbSection(
            type: "rockroot",
            gameState: _gameState,
            getCard: _getCard,
          ),
          HerbSection(
            type: "snowthistle",
            gameState: _gameState,
            getCard: _getCard,
          ),
          LootTypeHeader(type: "coin", amount: "1"),
          CoinRowsSection(
            start: 0,
            rows: _kCoin1Rows,
            gameState: _gameState,
            getCard: _getCard,
          ),
          const Divider(),
          LootTypeHeader(type: "coin", amount: "2"),
          CoinRowsSection(
            start: _kCoin2Start,
            rows: _kCoin2Rows,
            gameState: _gameState,
            getCard: _getCard,
          ),
          const Divider(),
          LootTypeHeader(type: "coin", amount: "3"),
          LootCardRow(
            type: "coin",
            start: _kCoin3Start,
            count: _kCoin3Count,
            gameState: _gameState,
            getCard: _getCard,
          ),
        ],
      ),
    );
  }
}
