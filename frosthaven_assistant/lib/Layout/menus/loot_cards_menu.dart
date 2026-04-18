import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/character_loot_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_card_enhancement_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_loot_owner_menu.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/add_special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/return_loot_card_command.dart';

import '../../Resource/commands/remove__special_loot_card_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../loot_card.dart';
import 'add_loot_card_menu.dart';

class LootCardsMenu extends StatefulWidget {
  const LootCardsMenu({
    super.key,
    this.gameState,
  });

  final GameState? gameState;

  @override
  LootCardsMenuState createState() => LootCardsMenuState();
}

class LootCardsMenuState extends State<LootCardsMenu> {
  static const double _kItemMaxWidth = 200.0;
  static const double _kGridAspectRatio = 0.72;
  static const int _kMinColumns = 4;
  static const double _kMaxHeightRatio = 0.9;
  static const double _kBottomBarHeight = 32.0;
  static const double _kItemMargin = 2.0;
  static const int _kCard1418 = 1418;
  static const int _kCard1419 = 1419;

  late final GameState _gameState;
  final scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
  }

  List<Widget> generateList(List<LootCard> inputList) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      var item = inputList[index];
      Item value = Item(key: Key(index.toString()), data: item);
      list.add(value);
    }
    return list;
  }

  Widget buildList(List<LootCard> list) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          child: GridView.count(
            controller: ScrollController(),
            childAspectRatio: _kGridAspectRatio,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            padding: EdgeInsets.zero,
            crossAxisCount:
                max(_kMinColumns, (screenWidth / _kItemMaxWidth).ceil()),
            children: generateList(list).reversed.toList(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          var discardPile = _gameState.lootDeck.discardPileContents.toList();

          return Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight:
                      MediaQuery.of(context).size.height * _kMaxHeightRatio),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4))),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        openDialog(
                                            context, const CharacterLootMenu());
                                      },
                                      child: const Text("Character loot"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_gameState.lootDeck.hasCard1418) {
                                            _gameState.action(
                                                RemoveSpecialLootCardCommand(
                                                    _kCard1418,
                                                    gameState: _gameState));
                                          } else {
                                            _gameState.action(
                                                AddSpecialLootCardCommand(
                                                    _kCard1418,
                                                    gameState: _gameState));
                                          }
                                        });
                                      },
                                      child: Text(
                                          _gameState.lootDeck.hasCard1418
                                              ? "Remove card $_kCard1418"
                                              : "Add card $_kCard1418"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_gameState.lootDeck.hasCard1419) {
                                            _gameState.action(
                                                RemoveSpecialLootCardCommand(
                                                    _kCard1419,
                                                    gameState: _gameState));
                                          } else {
                                            _gameState.action(
                                                AddSpecialLootCardCommand(
                                                    _kCard1419,
                                                    gameState: _gameState));
                                          }
                                        });
                                      },
                                      child: Text(
                                          _gameState.lootDeck.hasCard1419
                                              ? "Remove card $_kCard1419"
                                              : "Add card $_kCard1419"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        openDialog(context,
                                            const LootCardEnhancementMenu());
                                      },
                                      child: const Text("Enhance cards"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        openDialog(
                                            context, const AddLootCardMenu());
                                      },
                                      child: const Text("Add Card"),
                                    ),
                                    if (_gameState
                                        .lootDeck.discardPileIsNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              ReturnLootCardCommand(true,
                                                  gameState: _gameState));
                                        },
                                        child: const Text("Return to Top"),
                                      ),
                                    if (_gameState
                                        .lootDeck.discardPileIsNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              ReturnLootCardCommand(false,
                                                  gameState: _gameState));
                                        },
                                        child: const Text("Return to Bottom"),
                                      ),
                                  ],
                                ),
                              ])),
                      Flexible(
                          fit: FlexFit.tight, child: buildList(discardPile)),
                      Container(
                        height: _kBottomBarHeight,
                        margin: const EdgeInsets.all(_kItemMargin),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                      ),
                    ]),
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
                            })),
                  ])));
        });
  }
}

class Item extends StatelessWidget {
  static const double _kItemMaxWidth = 200.0;
  static const double _kMaxScale = 3.0;
  static const double _kItemMargin = 2.0;

  const Item({super.key, required this.data});
  final LootCard data;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = min(_kMaxScale, screenWidth / _kItemMaxWidth);

    late final Widget child;

    child = LootCardWidget.buildFront(data, scale, false);

    return Container(
        margin: EdgeInsets.all(_kItemMargin * scale),
        child: InkWell(
            onTap: () {
              openDialog(context, SetLootOwnerMenu(card: data));
            },
            child: child));
  }
}
