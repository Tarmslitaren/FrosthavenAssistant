import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_card_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/commands/reorder_ability_list_command.dart';
import '../../Resource/commands/shuffle_ability_card_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class Item extends StatelessWidget {
  final MonsterAbilityCardModel data;
  final Monster monsterData;
  final bool revealed;

  const Item({super.key, required this.data, required this.revealed, required this.monsterData});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = max((screenSize.height / (40 * 14)), 0.5);
    if (screenSize.width * 0.4 < 142.4 * scale) {
      scale = screenSize.width * 0.4 / (142.4);
    }
    late final Widget child;

    child = revealed
        ? MonsterAbilityCardWidget.buildFront(data, monsterData, scale, true)
        : MonsterAbilityCardWidget.buildRear(scale, -1, monsterData);

    return child;
  }
}

class AbilityCardMenu extends StatefulWidget {
  const AbilityCardMenu({super.key, required this.monsterAbilityState, required this.monsterData});

  final MonsterAbilityState monsterAbilityState;
  final Monster monsterData;

  @override
  AbilityCardMenuState createState() => AbilityCardMenuState();
}

class AbilityCardMenuState extends State<AbilityCardMenu> {
  final GameState _gameState = getIt<GameState>();
  static List<MonsterAbilityCardModel> revealedList = [];

  @override
  initState() {
    super.initState();
    revealedList = [];
  }

  void markAsOpen(int revealed) {
    setState(() {
      revealedList = [];
      var drawPile = widget.monsterAbilityState.drawPile.getList().reversed.toList();
      for (int i = 0; i < revealed; i++) {
        revealedList.add(drawPile[i]);
      }
    });
  }

  bool isRevealed(MonsterAbilityCardModel item) {
    for (var card in revealedList) {
      if (card.nr == item.nr) {
        return true;
      }
    }
    return false;
  }

  List<Widget> generateList(List<MonsterAbilityCardModel> inputList, bool allOpen) {
    List<Widget> list = [];
    for (var item in inputList) {
      Item value = Item(
          key: Key(item.nr.toString()),
          data: item,
          monsterData: widget.monsterData,
          revealed: isRevealed(item) || allOpen == true);
      {
        InkWell gestureDetector = InkWell(
          key: Key(item.nr.toString()),
          onTap: () {
            //open remove card menu
            openDialog(context, RemoveCardMenu(card: item));
          },
          child: value,
        );
        list.add(gestureDetector);
      }
    }
    return list;
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

  Widget buildList(List<MonsterAbilityCardModel> list, bool reorderable, bool allOpen) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
              Colors.transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
          width: screenWidth * 0.4,
          child: reorderable
              ? ReorderableColumn(
                  needsLongPressDraggable: true,
                  scrollController: ScrollController(),
                  scrollAnimationDuration: const Duration(milliseconds: 400),
                  reorderAnimationDuration: const Duration(milliseconds: 400),
                  buildDraggableFeedback: defaultBuildDraggableFeedback,
                  onReorder: (index, dropIndex) {
                    setState(() {
                      dropIndex = list.length - dropIndex - 1;
                      index = list.length - index - 1;
                      list.insert(dropIndex, list.removeAt(index));
                      _gameState.action(ReorderAbilityListCommand(
                          widget.monsterAbilityState.name, dropIndex, index));
                    });
                  },
                  children: generateList(list, allOpen),
                )
              : ListView(
                  controller: ScrollController(),
                  padding: EdgeInsets.zero,
                  children: generateList(list, allOpen).reversed.toList(),
                ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          var drawPile = widget.monsterAbilityState.drawPile.getList().reversed.toList();
          var discardPile = widget.monsterAbilityState.discardPile.getList();
          return Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
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
                                  topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                          child: Column(children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    runSpacing: 0,
                                    spacing: 0,
                                    children: [
                                      const Text(
                                        "  Reveal:",
                                      ),
                                      if (drawPile.length > 0)
                                        buildRevealButton(drawPile.length, 1),
                                      if (drawPile.length > 1)
                                        buildRevealButton(drawPile.length, 2),
                                      if (drawPile.length > 2)
                                        buildRevealButton(drawPile.length, 3),
                                      if (drawPile.length > 3)
                                        buildRevealButton(drawPile.length, 4),
                                      if (drawPile.length > 4)
                                        buildRevealButton(drawPile.length, 5),
                                      if (drawPile.length > 5)
                                        buildRevealButton(drawPile.length, 6),
                                      if (drawPile.length > 6)
                                        buildRevealButton(drawPile.length, 7),
                                      if (drawPile.length > 7)
                                        buildRevealButton(drawPile.length, 8),
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              DrawAbilityCardCommand(widget.monsterData.id));
                                        },
                                        child: const Text(
                                          "Draw extra card",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              ShuffleAbilityCardCommand(widget.monsterData.id));
                                        },
                                        child: const Text(
                                          "Extra Shuffle",
                                        ),
                                      ),
                                    ])),
                          ])),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false),
                          buildList(discardPile, false, true)
                        ],
                      )),
                      Container(
                        height: 32,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4))),
                      )
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
