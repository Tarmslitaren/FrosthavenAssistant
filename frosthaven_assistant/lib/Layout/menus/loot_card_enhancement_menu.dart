import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/enhance_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';

class LootCardEnhancementMenu extends StatefulWidget {
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
    // at the beginning, all items are shown
    super.initState();
  }

  Widget createCounterButton(LootCard card) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
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
              child: const Icon(Icons.remove, color: Colors.white, size: 32)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1), color: Colors.white),
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
                size: 32,
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
          height: 30,
          width: 30,
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
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Column(children: [
                          const Text(
                            "Loot Card Enhancements",
                            style: kTitleStyle,
                          ),
                          _createHeader("hide", "1"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("hide", 0)!),
                              createCounterButton(getCardFromIndex("hide", 1)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("hide", "2 for 2 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("hide", 2)!),
                              createCounterButton(getCardFromIndex("hide", 3)!),
                              createCounterButton(getCardFromIndex("hide", 4)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("hide", "2 for 2-3 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("hide", 5)!),
                              createCounterButton(getCardFromIndex("hide", 6)!),
                              createCounterButton(getCardFromIndex("hide", 7)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("lumber", "1"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("lumber", 0)!),
                              createCounterButton(
                                  getCardFromIndex("lumber", 1)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("lumber", "2 for 2 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("lumber", 2)!),
                              createCounterButton(
                                  getCardFromIndex("lumber", 3)!),
                              createCounterButton(
                                  getCardFromIndex("lumber", 4)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("lumber", "2 for 2-3 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("lumber", 5)!),
                              createCounterButton(
                                  getCardFromIndex("lumber", 6)!),
                              createCounterButton(
                                  getCardFromIndex("lumber", 7)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("metal", "1"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("metal", 0)!),
                              createCounterButton(getCardFromIndex("metal", 1)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("metal", "2 for 2 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("metal", 2)!),
                              createCounterButton(
                                  getCardFromIndex("metal", 3)!),
                              createCounterButton(getCardFromIndex("metal", 4)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("metal", "2 for 2-3 characters"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("metal", 5)!),
                              createCounterButton(
                                  getCardFromIndex("metal", 6)!),
                              createCounterButton(getCardFromIndex("metal", 7)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("arrowvine", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("arrowvine", 0)!),
                              createCounterButton(
                                  getCardFromIndex("arrowvine", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("axenut", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("axenut", 0)!),
                              createCounterButton(
                                  getCardFromIndex("axenut", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("corpsecap", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("corpsecap", 0)!),
                              createCounterButton(
                                  getCardFromIndex("corpsecap", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("flamefruit", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("flamefruit", 0)!),
                              createCounterButton(
                                  getCardFromIndex("flamefruit", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("rockroot", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("rockroot", 0)!),
                              createCounterButton(
                                  getCardFromIndex("rockroot", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("snowthistle", ""),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("snowthistle", 0)!),
                              createCounterButton(
                                  getCardFromIndex("snowthistle", 1)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("coin", "1"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("coin", 0)!),
                              createCounterButton(getCardFromIndex("coin", 1)!),
                              createCounterButton(getCardFromIndex("coin", 2)!),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("coin", 3)!),
                              createCounterButton(getCardFromIndex("coin", 4)!),
                              createCounterButton(getCardFromIndex("coin", 5)!)
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("coin", 6)!),
                              createCounterButton(getCardFromIndex("coin", 7)!),
                              createCounterButton(getCardFromIndex("coin", 8)!)
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(getCardFromIndex("coin", 9)!),
                              createCounterButton(
                                  getCardFromIndex("coin", 10)!),
                              createCounterButton(
                                  getCardFromIndex("coin", 11)!),
                            ],
                          ),
                          const Divider(),
                          _createHeader("coin", "2"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("coin", 12)!),
                              createCounterButton(
                                  getCardFromIndex("coin", 13)!),
                              createCounterButton(getCardFromIndex("coin", 14)!)
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("coin", 15)!),
                              createCounterButton(
                                  getCardFromIndex("coin", 16)!),
                              createCounterButton(getCardFromIndex("coin", 17)!)
                            ],
                          ),
                          const Divider(),
                          _createHeader("coin", "3"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createCounterButton(
                                  getCardFromIndex("coin", 18)!),
                              createCounterButton(getCardFromIndex("coin", 19)!)
                            ],
                          ),
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
