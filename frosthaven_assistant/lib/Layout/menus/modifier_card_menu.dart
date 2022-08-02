import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/enums.dart';
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

    return Container(margin: const EdgeInsets.all(2), child: child);
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
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
        width: max(screenSize.width / nrOfButtons - 40, 40),
        child: TextButton(
          child: Text(text),
          onPressed: () {
            markAsOpen(nr);
          },
        ));
  }

  List<Widget> generateList(List<ModifierCard> inputList, bool allOpen) {
    List<Widget> list = [];
    for (var item in inputList) {
      Item value = Item(
          key: UniqueKey(),
          data: item,
          revealed: isRevealed(item) || allOpen == true);
      list.add(value);
    }
    return list;
  }

  Widget buildList(List<ModifierCard> list, bool reorderable, bool allOpen) {
    var screenSize = MediaQuery.of(context).size;
    double scale = getScaleByReference(context);
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: Container(
          height: screenSize.height - 120,
          width: 88 * 2 * scale, //double scale??, since it's so small to begin with
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
    var drawPile = _gameState.modifierDeck.drawPile.getList().reversed.toList();
    var discardPile = _gameState.modifierDeck.discardPile.getList();
    return Container(
        child: Column(children: [
      Card(

          //color: Colors.transparent,
          //margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(children: [
        Row(mainAxisSize: MainAxisSize.max, children: [
          const Text(
            "Reveal:",
            //style: TextStyle(color: Colors.white)
          ),
          drawPile.length > 0
              ? buildRevealButton(drawPile.length, 1)
              : Container(),
          drawPile.length > 1
              ? buildRevealButton(drawPile.length, 2)
              : Container(),
          drawPile.length > 2
              ? buildRevealButton(drawPile.length, 3)
              : Container(),
          drawPile.length > 3
              ? buildRevealButton(drawPile.length, 4)
              : Container(),
          drawPile.length > 4
              ? buildRevealButton(drawPile.length, 5)
              : Container(),
          drawPile.length > 5
              ? buildRevealButton(drawPile.length, 6)
              : Container(),
          drawPile.length > 6
              ? buildRevealButton(drawPile.length, 7)
              : Container(),
          drawPile.length > 7
              ? buildRevealButton(drawPile.length, 8)
              : Container(),
        ]),
      ])),
      Card(
          color: Colors.transparent,
          //margin: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(children: [
            //TODO: add diviner functionality:,
            // bad omen (next 6 times place a curse 6th from the top),
            // enfeebling hex: shuffle x amount -1's to enemy deck
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildList(drawPile, true, false),
                buildList(discardPile, false, true)
              ],
            ),

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
          ]))
    ]));
  }
}
