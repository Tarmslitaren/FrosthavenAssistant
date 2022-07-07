import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/monster_ability_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';

import '../../Resource/enums.dart';
import '../../Resource/game_state.dart';
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

class AbilityCardMenu extends StatefulWidget {
  const AbilityCardMenu({Key? key, required this.monsterAbilityState, required this.monsterData})
      : super(key: key);

  final MonsterAbilityState monsterAbilityState;
  final Monster monsterData;

  @override
  _AbilityCardMenuState createState() => _AbilityCardMenuState();
}

class _AbilityCardMenuState extends State<AbilityCardMenu> {
  final GameState _gameState = getIt<GameState>();
  List<MonsterAbilityCardModel> _revealedList = [];

  @override
  initState() {
    super.initState();
  }

  void markAsOpen(int revealed) {
    setState(() {
      _revealedList = [];
      var drawPile = widget.monsterAbilityState.drawPile.getList().reversed.toList();
      for (int i = 0; i < revealed; i++) {
        _revealedList.add(drawPile[i]);
      }
    });
  }

  bool isRevealed(MonsterAbilityCardModel item) {
    for (var card in _revealedList) {
      if (card.nr == item.nr) {
        return true;
      }
    }
    return false;
  }

  bool isSameContent(MonsterAbilityCardModel a, MonsterAbilityCardModel b) {
    return false;
  }

  bool isSameItem(MonsterAbilityCardModel a, MonsterAbilityCardModel b) {
    return a.nr == b.nr;
  }

  Widget buildRevealButton(int nrOfButtons, int nr){
    String text = "All";
    if (nr < nrOfButtons){
      text = nr.toString();
    }
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width / nrOfButtons -15,
        child: TextButton(

          child: Text(text),
          onPressed: () {
            markAsOpen(nr);
            setState() {}
          },
        )
    );
  }

  Widget buildList(List<MonsterAbilityCardModel> list, bool reorderable,
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
          height: _gameState.roundState.value == RoundState.playTurns? screenSize.height * 0.86: screenSize.height * 0.94,
          width: 184 * tempScale * scale,
          //alignment: Alignment.centerLeft,
          //margin: EdgeInsets.only(left: getMainListMargin(context)),
          child: AutomaticAnimatedListView<MonsterAbilityCardModel>(
            //reverse: true,
            animator: const DefaultAnimatedListAnimator(),
            list: list,
            comparator: AnimatedListDiffListComparator<MonsterAbilityCardModel>(
                sameItem: (a, b) => isSameItem(a, b),
                sameContent: (a, b) => isSameContent(a, b)),
            itemBuilder: (context, item, data) => data.measuring
                ? Container(
                    color: Colors.transparent,
                    height: 120 * tempScale * scale,
                    //these are for smooth animations. need to be same size as the items
                  )
                : Item(
                    data: item,
                    monsterData: widget.monsterData,
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
                widget.monsterAbilityState.drawPile
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
        widget.monsterAbilityState.drawPile.getList().reversed.toList();
    var discardPile = widget.monsterAbilityState.discardPile.getList();
    return Column(children: [
      _gameState.roundState.value == RoundState.playTurns?
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
          ])): Container(),
      Card(
          color: Colors.transparent,
          margin: const EdgeInsets.only(left:20, right:20),
          child: Stack(children: [
            //TODO: add diviner functionality:, remove selected (how to mark selected?)
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
    ]);
  }
}
