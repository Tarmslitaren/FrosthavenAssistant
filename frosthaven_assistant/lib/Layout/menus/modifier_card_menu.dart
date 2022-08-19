import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/send_to_bottom_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/bad_omen_command.dart';
import 'package:frosthaven_assistant/Resource/commands/enfeebling_hex_command.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/game_state.dart';
import '../../Resource/modifier_deck_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class Item extends StatelessWidget {
  final ModifierCard data;
  final bool revealed;

  const Item({Key? key, required this.data, required this.revealed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context) * 2; //double scale
    late final Widget child;

    child = revealed
        ? ModifierCardWidget.buildFront(data, scale)
        : ModifierCardWidget.buildRear(scale);

    return Container(margin: EdgeInsets.all(2 * scale), child: child);
  }
}

class ModifierCardMenu extends StatefulWidget {
  const ModifierCardMenu({Key? key}) : super(key: key);

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

  void markAsOpen(int revealed) {
    setState(() {
      _revealedList = [];
      var drawPile =
          _gameState.modifierDeck.drawPile.getList().reversed.toList();
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

  Widget buildRevealButton(int nrOfButtons, int nr) {
    String text = "All";
    if (nr < nrOfButtons) {
      text = nr.toString();
    }
    return SizedBox(
        width: 32,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            markAsOpen(nr);
          },
        ));
  }

  List<Widget> generateList(List<ModifierCard> inputList, bool allOpen) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      var item = inputList[index];
      Item value = Item(
          key: Key(index.toString()),
          data: item,
          revealed: isRevealed(item) || allOpen == true);
      if (!allOpen) {
        GestureDetector gestureDetector = GestureDetector(
          key: Key(index.toString()),
          onTap: () {
            //open remove card menu
            String test = value.key
                .toString()
                .substring(3, value.key.toString().length - 3);
            openDialog(
                context,
                SendToBottomMenu(
                  currentIndex: int.parse(value.key
                      .toString()
                      .substring(3, value.key.toString().length - 3)),
                  length: inputList.length,
                ));
          },
          child: value,
        );
        list.add(gestureDetector);
      } else {
        list.add(value);
      }
    }
    return list;
  }

  Widget buildList(List<ModifierCard> list, bool reorderable, bool allOpen,
      bool hasDiviner) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: Container(
          // constraints: BoxConstraints(
          //minHeight: 400,
          // maxHeight: screenSize.height - 50,
          //),
          width: 118 * getScaleByReference(context), //184 * 0.8 *
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: scrollController,
                  scrollAnimationDuration: const Duration(milliseconds: 400),
                  reorderAnimationDuration: const Duration(milliseconds: 400),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    //make sure this is correct
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState
                          .action(ReorderModifierListCommand(dropIndex, index));
                    });
                  },
                  children: generateList(list, allOpen),
                )
              : ListView(
                  controller: ScrollController(),
                  children: generateList(list, allOpen).reversed.toList(),
                ),
        ));
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          var drawPile =
              _gameState.modifierDeck.drawPile.getList().reversed.toList();
          var discardPile = _gameState.modifierDeck.discardPile.getList();
          bool hasDiviner = false;
          for (var item in _gameState.currentList) {
            if (item is Character && item.characterClass.name == "Diviner") {
              hasDiviner = true;
            }
          }
          double scale = getScaleByReference(context);
          return Container(
              constraints: BoxConstraints(
                  maxWidth: 118 * scale * 2 + 8,
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
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
                                if (hasDiviner)
                                  Row(
                                    children: [
                                      if (_gameState
                                              .modifierDeck.badOmen.value ==
                                          0)
                                        TextButton(
                                          onPressed: () {
                                            _gameState.action(BadOmenCommand());
                                          },
                                          child: Text("Bad Omen"),
                                        ),
                                      if (_gameState
                                              .modifierDeck.badOmen.value >
                                          0)
                                        Text(
                                            "BadOmensLeft: ${_gameState.modifierDeck.badOmen.value}",
                                            style: getTitleTextStyle()),
                                      TextButton(
                                        onPressed: () {
                                          _gameState
                                              .action(EnfeeblingHexCommand());
                                        },
                                        child: Text(
                                            "Enfeebling Hex (added minus ones: ${_gameState.modifierDeck.addedMinusOnes.value})"),
                                      ),
                                    ],
                                  ),
                                Wrap(
                                    runSpacing: 0,
                                    spacing: 0,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        "   Reveal:",
                                        //style: TextStyle(color: Colors.white)
                                      ),
                                      drawPile.length > 0
                                          ? buildRevealButton(
                                              drawPile.length, 1)
                                          : Container(),
                                      drawPile.length > 1
                                          ? buildRevealButton(
                                              drawPile.length, 2)
                                          : Container(),
                                      drawPile.length > 2
                                          ? buildRevealButton(
                                              drawPile.length, 3)
                                          : Container(),
                                      drawPile.length > 3
                                          ? buildRevealButton(
                                              drawPile.length, 4)
                                          : Container(),
                                      drawPile.length > 4
                                          ? buildRevealButton(
                                              drawPile.length, 5)
                                          : Container(),
                                      drawPile.length > 5
                                          ? buildRevealButton(
                                              drawPile.length, 6)
                                          : Container(),
                                      drawPile.length > 6
                                          ? buildRevealButton(
                                              drawPile.length, 7)
                                          : Container(),
                                      drawPile.length > 7
                                          ? buildRevealButton(
                                              drawPile.length, 8)
                                          : Container(),
                                    ]),
                              ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false, hasDiviner),
                          buildList(discardPile, false, true, hasDiviner)
                        ],
                      )),
                      Container(
                        // color: Colors.white,
                        height: 32,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                      ),
                    ]),
                    Positioned(
                        width: 100,
                        right: 2,
                        bottom: 2,
                        child: TextButton(
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }))
                  ])));
        });
  }
}
