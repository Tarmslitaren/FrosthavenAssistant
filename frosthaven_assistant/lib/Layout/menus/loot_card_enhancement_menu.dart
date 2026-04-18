import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/enhance_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';

class LootCardEnhancementMenu extends StatefulWidget {
  static const double _kCounterPadding = 3.0;
  static const double _kCounterBorderRadius = 5.0;
  static const double _kIconSize = 32.0;
  static const double _kValuePaddingH = 6.0;
  static const double _kValuePaddingV = 4.0;
  static const double _kValueBorderRadius = 1.0;
  static const double _kHeaderImageSize = 30.0;
  static const double _kTopSpacing = 20.0;
  static const double _kMaxWidth = 300.0;
  static const double _kCoinRowSpacing = 6.0;

  // Pool layout: each material (hide/lumber/metal) has 8 cards: 2 + 3 + 3
  static const int _kMaterial1Count = 2;
  static const int _kMaterial2x2Start = _kMaterial1Count;
  static const int _kMaterial2x2Count = 3;
  static const int _kMaterial2x3Start = _kMaterial2x2Start + _kMaterial2x2Count;
  static const int _kMaterial2x3Count = 3;
  static const int _kHerbCount = 2;
  // Coin pool: "1" = 12 cards (4 rows of 3), "2" = 6 cards (2 rows of 3), "3" = 2 cards
  static const int _kCoinRowSize = 3;
  static const int _kCoin1Rows = 4;
  static const int _kCoin2Start = _kCoinRowSize * _kCoin1Rows;
  static const int _kCoin2Rows = 2;
  static const int _kCoin3Start = _kCoin2Start + _kCoinRowSize * _kCoin2Rows;
  static const int _kCoin3Count = 2;

  const LootCardEnhancementMenu({super.key, this.gameState});

  final GameState? gameState;

  @override
  LootCardEnhancementMenuState createState() => LootCardEnhancementMenuState();
}

class LootCardEnhancementMenuState extends State<LootCardEnhancementMenu> {
  late final GameState _gameState;

  @override
  initState() {
    _gameState = widget.gameState ?? getIt<GameState>();
    super.initState();
  }

  LootCard? getCardFromIndex(String type, int index) {
    if (type == "lumber") {
      return _gameState.lootDeck.lumberPool[index];
    }
    if (type == "hide") {
      return _gameState.lootDeck.hidePool[index];
    }
    if (type == "metal") {
      return _gameState.lootDeck.metalPool[index];
    }
    if (type == "arrowvine") {
      return _gameState.lootDeck.arrowvinePool[index];
    }
    if (type == "axenut") {
      return _gameState.lootDeck.axenutPool[index];
    }
    if (type == "corpsecap") {
      return _gameState.lootDeck.corpsecapPool[index];
    }
    if (type == "flamefruit") {
      return _gameState.lootDeck.flamefruitPool[index];
    }
    if (type == "rockroot") {
      return _gameState.lootDeck.rockrootPool[index];
    }
    if (type == "snowthistle") {
      return _gameState.lootDeck.snowthistlePool[index];
    }
    if (type == "coin") {
      return _gameState.lootDeck.coinPool[index];
    }
    return null;
  }

  List<Widget> _buildMaterialSection(String type) {
    return [
      _LootTypeHeader(type: type, amount: "1"),
      _LootCardRow(type: type, start: 0, count: LootCardEnhancementMenu._kMaterial1Count, gameState: _gameState, getCard: getCardFromIndex),
      const Divider(),
      _LootTypeHeader(type: type, amount: "2 for 2 characters"),
      _LootCardRow(type: type, start: LootCardEnhancementMenu._kMaterial2x2Start, count: LootCardEnhancementMenu._kMaterial2x2Count, gameState: _gameState, getCard: getCardFromIndex),
      const Divider(),
      _LootTypeHeader(type: type, amount: "2 for 2-3 characters"),
      _LootCardRow(type: type, start: LootCardEnhancementMenu._kMaterial2x3Start, count: LootCardEnhancementMenu._kMaterial2x3Count, gameState: _gameState, getCard: getCardFromIndex),
      const Divider(),
    ];
  }

  List<Widget> _buildHerbSection(String type) {
    return [
      _LootTypeHeader(type: type, amount: ""),
      _LootCardRow(type: type, start: 0, count: LootCardEnhancementMenu._kHerbCount, gameState: _gameState, getCard: getCardFromIndex),
      const Divider(),
    ];
  }

  List<Widget> _buildCoinRows(int start, int rows) {
    final result = <Widget>[];
    for (var row = 0; row < rows; row++) {
      result.add(_LootCardRow(type: "coin", start: start + row * LootCardEnhancementMenu._kCoinRowSize, count: LootCardEnhancementMenu._kCoinRowSize, gameState: _gameState, getCard: getCardFromIndex));
      if (row < rows - 1) {
        result.add(const SizedBox(height: LootCardEnhancementMenu._kCoinRowSpacing));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Card(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(height: LootCardEnhancementMenu._kTopSpacing),
                      Container(
                        constraints: const BoxConstraints(maxWidth: LootCardEnhancementMenu._kMaxWidth),
                        child: Column(children: [
                          const Text(
                            "Loot Card Enhancements",
                            style: kTitleStyle,
                          ),
                          ..._buildMaterialSection("hide"),
                          ..._buildMaterialSection("lumber"),
                          ..._buildMaterialSection("metal"),
                          ..._buildHerbSection("arrowvine"),
                          ..._buildHerbSection("axenut"),
                          ..._buildHerbSection("corpsecap"),
                          ..._buildHerbSection("flamefruit"),
                          ..._buildHerbSection("rockroot"),
                          ..._buildHerbSection("snowthistle"),
                          _LootTypeHeader(type: "coin", amount: "1"),
                          ..._buildCoinRows(0, LootCardEnhancementMenu._kCoin1Rows),
                          const Divider(),
                          _LootTypeHeader(type: "coin", amount: "2"),
                          ..._buildCoinRows(LootCardEnhancementMenu._kCoin2Start, LootCardEnhancementMenu._kCoin2Rows),
                          const Divider(),
                          _LootTypeHeader(type: "coin", amount: "3"),
                          _LootCardRow(type: "coin", start: LootCardEnhancementMenu._kCoin3Start, count: LootCardEnhancementMenu._kCoin3Count, gameState: _gameState, getCard: getCardFromIndex),
                        ]),
                      ),
                      const SizedBox(
                        height: kMenuCloseButtonSpacing,
                      ),
                    ],
                  ),
                  Positioned(
                      width: kCloseButtonWidth,
                      height: kButtonSize,
                      right: 0,
                      bottom: 0,
                      child: TextButton(
                          child: const Text(
                            'Close',
                            style: kButtonLabelStyle,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ]))));
  }
}

class _LootTypeHeader extends StatelessWidget {
  const _LootTypeHeader({required this.type, required this.amount});

  final String type;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(
          filterQuality: FilterQuality.medium,
          height: LootCardEnhancementMenu._kHeaderImageSize,
          width: LootCardEnhancementMenu._kHeaderImageSize,
          fit: BoxFit.contain,
          image: AssetImage("assets/images/loot/${type}_icon.png"),
        ),
        Text(
          "$type $amount",
          style: kBodyStyle,
        ),
      ],
    );
  }
}

class _LootCardRow extends StatelessWidget {
  const _LootCardRow({
    required this.type,
    required this.start,
    required this.count,
    required this.gameState,
    required this.getCard,
  });

  final String type;
  final int start;
  final int count;
  final GameState gameState;
  final LootCard? Function(String, int) getCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        count,
        (i) => _EnhancementCounterButton( // ignore: avoid-returning-widgets, widget generator lambda
            card: getCard(type, start + i)!, gameState: gameState),
      ),
    );
  }
}

class _EnhancementCounterButton extends StatelessWidget {
  const _EnhancementCounterButton({required this.card, required this.gameState});

  final LootCard card;
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: gameState.commandIndex,
        builder: (context, _, child) {
          return Container(
            padding: const EdgeInsets.all(LootCardEnhancementMenu._kCounterPadding),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(LootCardEnhancementMenu._kCounterBorderRadius)),
                color: Theme.of(context).colorScheme.secondary),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      if (card.enhanced > 0) {
                        gameState.action(EnhanceLootCardCommand(
                            card.id, card.enhanced - 1, card.gfx, gameState: gameState));
                      }
                    },
                    child: const Icon(Icons.remove, color: Colors.white, size: LootCardEnhancementMenu._kIconSize)),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: LootCardEnhancementMenu._kCounterPadding),
                  padding: const EdgeInsets.symmetric(
                      horizontal: LootCardEnhancementMenu._kValuePaddingH,
                      vertical: LootCardEnhancementMenu._kValuePaddingV),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(LootCardEnhancementMenu._kValueBorderRadius)),
                      color: Colors.white),
                  child: Text(
                    card.enhanced.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: kFontSizeTitle),
                  ),
                ),
                InkWell(
                    onTap: () {
                      gameState.action(EnhanceLootCardCommand(
                          card.id, card.enhanced + 1, card.gfx, gameState: gameState));
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: LootCardEnhancementMenu._kIconSize)),
              ],
            ),
          );
        });
  }
}
