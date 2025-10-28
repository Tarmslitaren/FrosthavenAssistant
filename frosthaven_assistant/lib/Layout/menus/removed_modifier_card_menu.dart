import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/return_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class RemovedModifierCardMenu extends StatefulWidget {
  const RemovedModifierCardMenu({super.key, required this.name});

  final String name;

  @override
  RemovedModifierCardMenuState createState() => RemovedModifierCardMenuState();
}

class RemovedModifierCardMenuState extends State<RemovedModifierCardMenu> {
  final GameState _gameState = getIt<GameState>();
  final scrollController = ScrollController();

  List<Widget> generateList(List<ModifierCard> inputList, String name) {
    List<Widget> list = [];
    for (int index = 0; index < inputList.length; index++) {
      final key = index.toString();
      var item = inputList[index];
      Item value = Item(key: Key(key), data: item, name: name, revealed: true);
      InkWell gestureDetector = InkWell(
        key: Key(index.toString()),
        onTap: () {
          //open remove card menu
          openDialog(context, ReturnAMDCardMenu(index: index, name: name));
        },
        child: value,
      );
      //reason for row is to force wrap width of ListView
      list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          key: Key(index.toString()),
          children: [gestureDetector]));
    }
    return list;
  }

  Widget buildList(List<ModifierCard> list) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          width: screenWidth * 0.3,
          child: ListView(
            controller: ScrollController(),
            children: generateList(list, widget.name).reversed.toList(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          String name = widget.name;
          ModifierDeck deck =
              GameMethods.getModifierDeck(widget.name, _gameState);
          final removedPile = deck.removedPile.getList();

          bool isCharacter = widget.name.isNotEmpty && widget.name != "allies";
          final character =
              isCharacter ? GameMethods.getCharacterByName(widget.name) : null;
          final screenSize = MediaQuery.of(context).size;
          final monsterDeck = widget.name.isEmpty;
          final textStyle = TextStyle(fontSize: 16, color: Colors.black);

          return Container(
              constraints: BoxConstraints(
                  maxWidth: screenSize.width,
                  maxHeight: screenSize.height * 0.9),
              child: Card(
                  color: Colors.transparent,
                  child: Stack(children: [
                    Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                          width: screenSize.width, //need some width to fill out
                          margin: const EdgeInsets.all(2),
                          padding: EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "   Removed cards",
                                ),
                              ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [buildList(removedPile)],
                      )),
                      Container(
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

class Item extends StatelessWidget {
  const Item(
      {super.key,
      required this.data,
      required this.revealed,
      required this.name});

  final ModifierCard data;
  final bool revealed;
  final String name;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = max((screenSize.height / (40 * 12)), 1);
    final Widget child = revealed
        ? ModifierCardWidget.buildFront(data, name, scale, 2)
        : ModifierCardWidget.buildRear(scale, name);

    return Container(margin: EdgeInsets.all(2 * scale), child: child);
  }
}
