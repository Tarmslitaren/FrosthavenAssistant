
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/monster_ability_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';

import '../../Resource/enums.dart';
import '../../Resource/game_state.dart';
import '../../Resource/modifier_deck_state.dart';
import '../../services/service_locator.dart';

class Item extends StatelessWidget {
  final MonsterAbilityCardModel data;
  final Monster monsterData;
  final bool revealed;

  const Item({Key? key, required this.data, required this.revealed, required this.monsterData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    late final Widget child;
    //late final double height;
    final GameState _gameState = getIt<GameState>();

    child = revealed
        ? MonsterAbilityCardWidget.buildFront(data, monsterData, scale, true)
        : MonsterAbilityCardWidget.buildRear(scale, -1);
    //height = 120 * tempScale * scale;

    return child;

  }
}

class ModifierCardMenu extends StatefulWidget {
  const ModifierCardMenu({Key? key})
      : super(key: key);

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
      var drawPile =_gameState.modifierDeck.drawPile.getList().reversed.toList();
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

  bool isSameContent(ModifierCard a, ModifierCard b) {
    return a.gfx == b.gfx;
  }

  bool isSameItem(ModifierCard a, ModifierCard b) {
    return false; //TODO: not exactly. this f's stuff up
  }

  Widget buildRevealButton(int nrOfButtons, int nr){
    String text = "All";
    if (nr < nrOfButtons){
      text = nr.toString();
    }
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
        width: max(screenSize.width / nrOfButtons -15,20),
        child: TextButton(

          child: Text(text),
          onPressed: () {
            markAsOpen(nr);
            setState() {}
          },
        )
    );
  }

  Widget buildList(List<ModifierCard> list, bool reorderable,
      bool allOpen, var controller) {
    var screenSize = MediaQuery.of(context).size;
    double scale = getScaleByReference(context);
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: Container(
          height: screenSize.height * 0.80,
          width: 88,
          //alignment: Alignment.centerLeft,
          //margin: EdgeInsets.only(left: getMainListMargin(context)),
          child: AutomaticAnimatedListView<ModifierCard>(
            //reverse: true,
            animator: const DefaultAnimatedListAnimator(),
            list: list,
            comparator: AnimatedListDiffListComparator<ModifierCard>(
                sameItem: (a, b) => isSameItem(a, b, ),
                sameContent: (a, b) => isSameContent(a, b)),
            itemBuilder: (context, item, data) => data.measuring
                ? Container(
              color: Colors.transparent,
              height: 60,
              //these are for smooth animations. need to be same size as the items
            )
                : ModifierCardWidget(card: item,
                revealed: isRevealed(item) || allOpen == true),
            listController: controller,
            //scrollController: ScrollController(),
            addLongPressReorderable: reorderable,

            reorderModel: AnimatedListReorderModel(
              onReorderStart: (index, dx, dy) {
                return true;
              },
              onReorderMove: (index, dropIndex) {
                // pink-colored items cannot be swapped
                return true; //list[dropIndex].color != 3;
              },
              onReorderComplete: (index, dropIndex, slot) {
                list.insert(dropIndex, list.removeAt(index));
                _gameState.modifierDeck.drawPile
                    .setList(list.reversed.toList());
                return true;
              },
            ),

            //reorderModel: AutomaticAnimatedListReorderModel(list),
          ),
        ));
  }

  final scrollController = ScrollController();

  //use to animate to position in list:
  final controller = AnimatedListController();
  final controller2 = AnimatedListController();

  @override
  Widget build(BuildContext context) {
    var drawPile =
    _gameState.modifierDeck.drawPile.getList().reversed.toList();
    var discardPile = _gameState.modifierDeck.discardPile.getList();
    return Container(
      //TODO: fix layout size for this.
      //width: 500,
      // height: 300,
        child:
        Column(children: [
          Card(

            //color: Colors.transparent,
              margin: const EdgeInsets.only(left:20, right:20, top: 20),

              child: Column(children: [

                Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
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
                          ?buildRevealButton(drawPile.length, 7)
                          :Container(),
                    ]),
              ])),
          Card(
              color: Colors.transparent,
              margin: const EdgeInsets.only(left:20, right:20),
              child: Stack(children: [
                //TODO: add diviner functionality:send ot bottom, bad omen, enfeebling hex
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildList(drawPile, _gameState.roundState.value == RoundState.playTurns, false, controller),
                    buildList(discardPile, false, true, controller2)
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
