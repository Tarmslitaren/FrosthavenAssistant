import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/monster_ability_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:great_list_view/great_list_view.dart';

import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class Item extends StatelessWidget {
  final MonsterAbilityCardModel data;
  final bool revealed;

  const Item({Key? key, required this.data, required this.revealed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    late final Widget child;
    late final double height;

    child = revealed
        ? MonsterAbilityCardWidget.buildFront(data, scale)
        : MonsterAbilityCardWidget.buildRear(scale, -1); // * 1.085);
    height = 120 * tempScale * scale;

    return child;

    return AnimatedContainer(
      height: height,
      duration: const Duration(milliseconds: 500),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: child,
    );
  }
}

class AbilityCardMenu extends StatefulWidget {
  const AbilityCardMenu({Key? key, required this.monsterAbilityState})
      : super(key: key);

  final MonsterAbilityState monsterAbilityState;

  @override
  _AbilityCardMenuState createState() => _AbilityCardMenuState();
}

class _AbilityCardMenuState extends State<AbilityCardMenu> {
  final GameState _gameState = getIt<GameState>();
  final _fuckingShit = ValueNotifier<List<MonsterAbilityCardModel>>([]);
  final _fuckingShitFuck = ValueNotifier<int>(0);

  @override
  initState() {
    super.initState();
  }

  void markAsOpen(int revealed) {
    setState(() {
      _fuckingShit.value = [];
      var drawPile =
          widget.monsterAbilityState.drawPile.getList().reversed.toList();
      for (int i = 0; i < revealed; i++) {
        _fuckingShit.value.add(drawPile[i]);
      }
    });
    _fuckingShitFuck.value = revealed;
  }

  bool isRevealed(MonsterAbilityCardModel item) {
    for (var card in _fuckingShit.value) {
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
      bool reverse, var controller) {
    var screenSize = MediaQuery.of(context).size;
    double scale = getScaleByReference(context);
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: Container(
          height: screenSize.height * 0.86,
          width: 188 * tempScale * scale,
          //a bit disgusting that I need to set the exact width of the cards here.
          //alignment: Alignment.centerLeft,
          //margin: EdgeInsets.only(left: getMainListMargin(context)),
          child: AutomaticAnimatedListView<MonsterAbilityCardModel>(
            reverse: reverse,
            animator: const DefaultAnimatedListAnimator(),
            list: list,
            comparator: AnimatedListDiffListComparator<MonsterAbilityCardModel>(
                sameItem: (a, b) => isSameItem(a, b),
                sameContent: (a, b) => isSameContent(a, b)),
            itemBuilder: (context, item, data) => data.measuring
                ? Container(
                    color: Colors.transparent,
                    height: 120 * tempScale * scale,
                    //TODO: these are for smooth animations. need to be same size as the items
                  )
                : Item(
                    data: item,
                    revealed: isRevealed(item) || reorderable == false),
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
      _gameState.roundState.value == RoundState.playTurns || true?
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
              drawPile.length > 1
                  ? buildRevealButton(drawPile.length, 1)
                  : Container(),
              drawPile.length > 2
                  ? buildRevealButton(drawPile.length, 2)
                  : Container(),
              drawPile.length > 3
                  ? buildRevealButton(drawPile.length, 3)
                  : Container(),
              drawPile.length > 4
                  ? buildRevealButton(drawPile.length, 4)
                  : Container(),
              drawPile.length > 5
                  ? buildRevealButton(drawPile.length, 5)
                  : Container(),
              drawPile.length > 6
                  ? buildRevealButton(drawPile.length, 6)
                  : Container(),
                  buildRevealButton(drawPile.length, 7)
            ]),
          ])): Container(),
      Card(
          color: Colors.transparent,
          margin: const EdgeInsets.only(left:20, right:20),
          child: Stack(children: [
            //TODO: add diviner functionality:, remove selected (how to mark selected?)
            Row(
              //TODO: center on screen
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: _fuckingShitFuck,
                    builder: (context, value, child) {
                      return buildList(drawPile, true, false, controller);
                    }),
                buildList(discardPile, false, false, controller2)
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
