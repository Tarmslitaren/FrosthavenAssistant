import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/amd_remove_minus_1_command.dart';
import 'package:frosthaven_assistant/Resource/commands/bad_omen_command.dart';
import 'package:frosthaven_assistant/Resource/commands/enfeebling_hex_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/commands/amd_remove_minus_2_command.dart';
import '../../Resource/commands/change_stat_commands/change_bless_command.dart';
import '../../Resource/commands/change_stat_commands/change_curse_command.dart';
import '../../Resource/commands/change_stat_commands/change_enfeeble_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';
import '../counter_button.dart';

class Item extends StatelessWidget {
  final ModifierCard data;
  final bool revealed;
  final String name;

  const Item({super.key, required this.data, required this.revealed, required this.name});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = max((screenSize.height / (40 * 12)), 1);
    late final Widget child;

    child = revealed
        ? ModifierCardWidget.buildFront(data, scale)
        : ModifierCardWidget.buildRear(scale, name);

    return Container(margin: EdgeInsets.all(2 * scale), child: child);
  }
}

class ModifierCardMenu extends StatefulWidget {
  const ModifierCardMenu({super.key, required this.name});

  final String name;

  @override
  ModifierCardMenuState createState() => ModifierCardMenuState();
}

class ModifierCardMenuState extends State<ModifierCardMenu> {
  final GameState _gameState = getIt<GameState>();
  List<ModifierCard> _revealedList = [];

  @override
  initState() {
    super.initState();
  }

  void markAsOpen(int revealed, ModifierDeck deck) {
    setState(() {
      _revealedList = [];
      var drawPile = deck.drawPile.getList().reversed.toList();
      for (int i = 0; i < revealed; i++) {
        _revealedList.add(drawPile[i]);
      }
    });
  }

  bool isRevealed(ModifierCard item) {
    for (var card in _revealedList) {
      if (card == item) {
        return true;
      }
    }
    return false;
  }

  Widget buildRevealButton(int nrOfButtons, int nr, ModifierDeck deck) {
    String text = "All";
    if (nr < nrOfButtons) {
      text = nr.toString();
    }
    return SizedBox(
        width: 32,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            markAsOpen(nr, deck);
          },
        ));
  }

  List<Widget> generateList(List<ModifierCard> inputList, bool allOpen, String name) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      var item = inputList[index];
      Item value = Item(
          key: Key(index.toString()),
          data: item,
          name: name,
          revealed: isRevealed(item) || allOpen == true);
      if (!allOpen) {
        InkWell gestureDetector = InkWell(
          key: Key(index.toString()),
          onTap: () {
            //open remove card menu
            openDialog(
                context,
                SendToBottomMenu(
                  currentIndex:
                      int.parse(value.key.toString().substring(3, value.key.toString().length - 3)),
                  length: inputList.length,
                  allies: name == "allies",
                ));
          },
          child: value,
        );
        list.add(gestureDetector);
      } else {
        InkWell gestureDetector = InkWell(
          key: Key(index.toString()),
          onTap: () {
            //open remove card menu
            openDialog(
                context,
                RemoveAMDCardMenu(
                  index: index,
                  allyDeck: name == "allies",
                ));
          },
          child: value,
        );
        list.add(gestureDetector);
      }
    }
    return list;
  }

  Widget buildList(
      List<ModifierCard> list, bool reorderable, bool allOpen, bool hasDiviner, String name) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
              Colors.transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          width: screenWidth * 0.3,
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: scrollController,
                  scrollAnimationDuration: const Duration(milliseconds: 400),
                  reorderAnimationDuration: const Duration(milliseconds: 400),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState
                          .action(ReorderModifierListCommand(dropIndex, index, name == "allies"));
                    });
                  },
                  children: generateList(list, allOpen, name),
                )
              : ListView(
                  controller: ScrollController(),
                  children: generateList(list, allOpen, name).reversed.toList(),
                ),
        ));
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          String name = widget.name;
          if (name.isEmpty) {
            name = "Enemies";
          }
          ModifierDeck deck = _gameState.modifierDeck;
          if (name != "Enemies") {
            deck = _gameState.modifierDeckAllies;
          }
          var drawPile = deck.drawPile.getList().reversed.toList();
          var discardPile = deck.discardPile.getList();
          bool hasDiviner = false;
          for (var item in _gameState.currentList) {
            if (item is Character && item.characterClass.name == "Diviner") {
              hasDiviner = true;
            }
          }

          return Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                          width: MediaQuery.of(context).size.width, //need some width to fill out
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 0,
                              spacing: 0,
                              children: [
                                if (hasDiviner)
                                  if (deck.badOmen.value == 0)
                                    TextButton(
                                      onPressed: () {
                                        _gameState.action(BadOmenCommand(name == "allies"));
                                      },
                                      child: const Text("Bad Omen"),
                                    ),
                                if (deck.badOmen.value > 0)
                                  Text("BadOmensLeft: ${deck.badOmen.value}",
                                      style: getTitleTextStyle(1)),
                                TextButton(
                                  onPressed: () {
                                    _gameState.action(EnfeeblingHexCommand(name == "allies"));
                                  },
                                  child: Text("Add -1 card (added : ${deck.addedMinusOnes.value})"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (deck.hasMinus1()) {
                                      _gameState.action(AMDRemoveMinus1Command(name == "allies"));
                                    }
                                  },
                                  child: const Text("Remove -1 card"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _gameState.action(AMDRemoveMinus2Command(name == "allies"));
                                  },
                                  child: Text(
                                    deck.hasMinus2() ? "Remove -2 card" : "-2 card removed",
                                  ),
                                ),
                                //todo: (gray out if maxed out)
                                CounterButton(deck.blesses, ChangeBlessCommand.deck(deck), 10,
                                    "assets/images/abilities/bless.png", true, Colors.white,
                                    figureId: "unknown", ownerId: "unknown", scale: 1),
                                CounterButton(deck.curses, ChangeCurseCommand.deck(deck), 10,
                                    "assets/images/abilities/curse.png", true, Colors.white,
                                    figureId: "unknown", ownerId: "unknown", scale: 1),
                                if (GameMethods.getFigure("Incarnate", "Incarnate") != null)
                                  CounterButton(
                                      deck.enfeebles,
                                      ChangeEnfeebleCommand.deck(deck),
                                      10,
                                      "assets/images/abilities/enfeeble.png",
                                      true,
                                      Colors.white,
                                      figureId: "unknown",
                                      ownerId: "unknown",
                                      scale: 1),

                                const Text(
                                  "   Reveal:",
                                ),
                                drawPile.length > 0
                                    ? buildRevealButton(drawPile.length, 1, deck)
                                    : Container(),
                                drawPile.length > 1
                                    ? buildRevealButton(drawPile.length, 2, deck)
                                    : Container(),
                                drawPile.length > 2
                                    ? buildRevealButton(drawPile.length, 3, deck)
                                    : Container(),
                                drawPile.length > 3
                                    ? buildRevealButton(drawPile.length, 4, deck)
                                    : Container(),
                                drawPile.length > 4
                                    ? buildRevealButton(drawPile.length, 5, deck)
                                    : Container(),
                                drawPile.length > 5
                                    ? buildRevealButton(drawPile.length, 6, deck)
                                    : Container(),
                              ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false, hasDiviner, widget.name),
                          buildList(discardPile, false, true, hasDiviner, widget.name)
                        ],
                      )),
                      Container(
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
                    Positioned(
                        bottom: 4,
                        left: 20,
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 20),
                        ))
                  ])));
        });
  }
}
