// ignore_for_file: avoid-returning-widgets, file uses widget helper methods for loot card layout sections
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

  Widget createCounterButton(LootCard card) {
    return Container(
      padding: const EdgeInsets.all(LootCardEnhancementMenu._kCounterPadding),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(LootCardEnhancementMenu._kCounterBorderRadius)),
          color: Theme.of(context).colorScheme.secondary),
      child: Row(
        children: [
          InkWell(
              onTap: () {
                setState(() {
                  if (card.enhanced > 0) {
                    _gameState.action(EnhanceLootCardCommand(
                        card.id, card.enhanced - 1, card.gfx, gameState: _gameState));
                  }
                });
              },
              child: const Icon(Icons.remove, color: Colors.white, size: LootCardEnhancementMenu._kIconSize)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: LootCardEnhancementMenu._kCounterPadding),
            padding: const EdgeInsets.symmetric(horizontal: LootCardEnhancementMenu._kValuePaddingH, vertical: LootCardEnhancementMenu._kValuePaddingV),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(LootCardEnhancementMenu._kValueBorderRadius)), color: Colors.white),
            child: Text(
              card.enhanced.toString(),
              style: const TextStyle(color: Colors.black, fontSize: kFontSizeTitle),
            ),
          ),
          InkWell(
              onTap: () {
                setState(() {
                  _gameState.action(EnhanceLootCardCommand(
                      card.id, card.enhanced + 1, card.gfx, gameState: _gameState));
                });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: LootCardEnhancementMenu._kIconSize,
              )),
        ],
      ),
    );
  }

  Widget _createHeader(String type, String amount) {
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

  Widget _buildRow(String type, int start, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        count,
        (i) => createCounterButton(getCardFromIndex(type, start + i)!),
      ),
    );
  }

  List<Widget> _buildMaterialSection(String type) {
    return [
      _createHeader(type, "1"),
      _buildRow(type, 0, LootCardEnhancementMenu._kMaterial1Count),
      const Divider(),
      _createHeader(type, "2 for 2 characters"),
      _buildRow(type, LootCardEnhancementMenu._kMaterial2x2Start, LootCardEnhancementMenu._kMaterial2x2Count),
      const Divider(),
      _createHeader(type, "2 for 2-3 characters"),
      _buildRow(type, LootCardEnhancementMenu._kMaterial2x3Start, LootCardEnhancementMenu._kMaterial2x3Count),
      const Divider(),
    ];
  }

  List<Widget> _buildHerbSection(String type) {
    return [
      _createHeader(type, ""),
      _buildRow(type, 0, LootCardEnhancementMenu._kHerbCount),
      const Divider(),
    ];
  }

  List<Widget> _buildCoinRows(int start, int rows) {
    final result = <Widget>[];
    for (var row = 0; row < rows; row++) {
      result.add(_buildRow("coin", start + row * LootCardEnhancementMenu._kCoinRowSize, LootCardEnhancementMenu._kCoinRowSize));
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
                          _createHeader("coin", "1"),
                          ..._buildCoinRows(0, LootCardEnhancementMenu._kCoin1Rows),
                          const Divider(),
                          _createHeader("coin", "2"),
                          ..._buildCoinRows(LootCardEnhancementMenu._kCoin2Start, LootCardEnhancementMenu._kCoin2Rows),
                          const Divider(),
                          _createHeader("coin", "3"),
                          _buildRow("coin", LootCardEnhancementMenu._kCoin3Start, LootCardEnhancementMenu._kCoin3Count),
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
