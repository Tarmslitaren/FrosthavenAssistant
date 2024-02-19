import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/character_loot_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/loot_card_enhancement_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/set_loot_owner_menu.dart';
import 'package:frosthaven_assistant/Resource/commands/add__special_loot_card_command.dart';
import 'package:frosthaven_assistant/Resource/commands/return_loot_card_command.dart';

import '../../Resource/commands/remove__special_loot_card_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../loot_card.dart';
import 'add_loot_card_menu.dart';

class Item extends StatelessWidget {
  final LootCard data;

  const Item({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double wantedItemMaxWidth = 200;
    double maxScale = 3;
    double scale = min(maxScale, screenWidth / wantedItemMaxWidth);

    late final Widget child;

    child = LootCardWidget.buildFront(data, scale);

    return Container(
        margin: EdgeInsets.all(2 * scale),
        child: InkWell(
            onTap: () {
              openDialog(context, SetLootOwnerMenu(card: data));
            },
            child: child));
  }
}

class LootCardMenu extends StatefulWidget {
  const LootCardMenu({super.key});

  @override
  LootCardMenuState createState() => LootCardMenuState();
}

class LootCardMenuState extends State<LootCardMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
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
    double wantedItemMaxWidth = 200;
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
              Colors.transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          child: GridView.count(
            controller: ScrollController(),
            childAspectRatio: 0.72,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            padding: EdgeInsets.zero,
            crossAxisCount: max(4, (screenWidth / wantedItemMaxWidth).ceil()),
            children: generateList(list).reversed.toList(),
          ),
        ));
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          var discardPile = _gameState.lootDeck.discardPile.getList();

          return Container(
              constraints: BoxConstraints(
                  //maxWidth: 118 * scale * 2 + 98,
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                                  topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        openDialog(context, const CharacterLootMenu());
                                      },
                                      child: const Text("Character loot"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_gameState.lootDeck.hasCard1418) {
                                            _gameState.action(RemoveSpecialLootCardCommand(1418));
                                          } else {
                                            _gameState.action(AddSpecialLootCardCommand(1418));
                                          }
                                        });
                                      },
                                      child: Text(_gameState.lootDeck.hasCard1418
                                          ? "Remove card 1418"
                                          : "Add card 1418"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_gameState.lootDeck.hasCard1419) {
                                            _gameState.action(RemoveSpecialLootCardCommand(1419));
                                          } else {
                                            _gameState.action(AddSpecialLootCardCommand(1419));
                                          }
                                        });
                                      },
                                      child: Text(_gameState.lootDeck.hasCard1419
                                          ? "Remove card 1419"
                                          : "Add card 1419"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        openDialog(context, const LootCardEnhancementMenu());
                                      },
                                      child: const Text("Enhance cards"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        openDialog(context, const AddLootCardMenu());
                                      },
                                      child: const Text("Add Card"),
                                    ),
                                    if (_gameState.lootDeck.discardPile.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(ReturnLootCardCommand(true));
                                        },
                                        child: const Text("Return to Top"),
                                      ),
                                    if (_gameState.lootDeck.discardPile.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(ReturnLootCardCommand(false));
                                        },
                                        child: const Text("Return to Bottom"),
                                      ),
                                  ],
                                ),
                              ])),
                      Flexible(fit: FlexFit.tight, child: buildList(discardPile)),
                      Container(
                        // color: Colors.white,
                        height: 32,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4))),
                      ),
                    ]),
                    Positioned(
                        width: 100,
                        height: 40,
                        right: 0,
                        bottom: 0,
                        child: TextButton(
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                  ])));
        });
  }
}
