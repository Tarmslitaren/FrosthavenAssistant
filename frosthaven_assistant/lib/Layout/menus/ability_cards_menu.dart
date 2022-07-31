
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/monster_ability_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:reorderables/reorderables.dart';
import '../../Resource/commands/reorder_ability_list_command.dart';
import '../../Resource/enums.dart';
import '../../Resource/game_state.dart';
import '../../Resource/ui_utils.dart';
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

    child = revealed
        ? MonsterAbilityCardWidget.buildFront(data, monsterData, scale, true)
        : MonsterAbilityCardWidget.buildRear(scale, -1);

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

  List<Widget> generateList(
      List<MonsterAbilityCardModel> inputList, bool allOpen) {
    List<Widget> list = [];
    for (var item in inputList) {
      Item value = Item(
          key: Key(item.nr.toString()),
          data: item,
          monsterData: widget.monsterData,
          revealed: isRevealed(item) || allOpen == true);
      list.add(value);
    }
    return list;
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
          },
        )
    );
  }

  Widget buildList(List<MonsterAbilityCardModel> list, bool reorderable,
      bool allOpen) {
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
          width: 184 * 0.8 * scale,
          child: reorderable? ReorderableColumn(
            needsLongPressDraggable: true,
            scrollController: scrollController,
            scrollAnimationDuration: Duration(milliseconds: 400),
            reorderAnimationDuration: Duration(milliseconds: 400),

            buildDraggableFeedback: defaultBuildDraggableFeedback,
            onReorder: (index, dropIndex) {
              //make sure this is correct
              setState(() {
                dropIndex = list.length -dropIndex-1;
                index = list.length-index-1;
                list.insert(dropIndex, list.removeAt(index));
                _gameState.action(ReorderAbilityListCommand(
                    widget.monsterAbilityState.name, dropIndex, index));
              });
            },
            children: generateList(list, allOpen),

          ):
            ListView(
              //reverse: true,
              children: generateList(list, allOpen).reversed.toList(),
            ),
        ));
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var drawPile =
        widget.monsterAbilityState.drawPile.getList().reversed.toList();
    var discardPile = widget.monsterAbilityState.discardPile.getList();
    return Container(
      //TODO: fix layout size for this.
      //width: 500,
       // height: 300,
        child:
      Column(children: [
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
                buildList(drawPile, _gameState.roundState.value == RoundState.playTurns, false),
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
