import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/remove_card_menu.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card_widget.dart';
import 'package:frosthaven_assistant/Model/monster_ability.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/Resource/commands/activate_monster_type_command.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_ability_card_command.dart';
import 'package:reorderables/reorderables.dart';

import '../../Resource/commands/reorder_ability_list_command.dart';
import '../../Resource/commands/shuffle_ability_card_command.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class AbilityCardsMenu extends StatefulWidget {
  const AbilityCardsMenu(
      {super.key,
      required this.monsterAbilityState,
      required this.monsterData,
      this.gameState});

  final MonsterAbilityState monsterAbilityState;
  final Monster monsterData;

  final GameState? gameState;

  @override
  AbilityCardsMenuState createState() => AbilityCardsMenuState();
}

class AbilityCardsMenuState extends State<AbilityCardsMenu> {
  static const double _kBarSize = 32.0;
  static const double _kListWidthRatio = 0.4;
  static const double _kMaxHeightRatio = 0.9;
  static const int _kMaxRevealButtons = 8;

  GameState get _gameState => widget.gameState ?? getIt<GameState>();
  static final List<MonsterAbilityCardModel> revealedList = [];

  @override
  initState() {
    super.initState();
    revealedList.clear();
  }

  void markAsOpen(int revealed) {
    setState(() {
      revealedList.clear();
      var drawPile =
          widget.monsterAbilityState.drawPileContents.reversed.toList();
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

  List<Widget> generateList(
      List<MonsterAbilityCardModel> inputList, bool allOpen) {
    List<Widget> list = [];
    for (var item in inputList) {
      final nrString = item.nr.toString();
      Item value = Item(
          key: Key(nrString),
          data: item,
          monsterData: widget.monsterData,
          revealed: isRevealed(item) || allOpen);
      {
        InkWell gestureDetector = InkWell(
          key: Key(nrString),
          onTap: () {
            //open remove card menu
            openDialog(context, RemoveCardMenu(card: item));
          },
          child: value,
        );
        list.add(
            //reason for row is to force wrap width of ListView
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                key: Key(nrString),
                children: [gestureDetector]));
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
        width: _kBarSize,
        child: TextButton(
          child: Text(text),
          onPressed: () {
            markAsOpen(nr);
          },
        ));
  }

  Widget buildList(
      List<MonsterAbilityCardModel> list, bool reorderable, bool allOpen) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors
              .transparent, //needed to make background transparent if reorder is enabled
          //other styles
        ),
        child: SizedBox(
            width: screenWidth * _kListWidthRatio,
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
                            widget.monsterAbilityState.name, dropIndex, index,
                            gameState: _gameState));
                      });
                    },
                    children: generateList(list, allOpen),
                  )
                : ListView(
                    clipBehavior: Clip.none,
                    controller: ScrollController(),
                    padding: EdgeInsets.zero,
                    children: generateList(list, allOpen).reversed.toList(),
                  )));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          var drawPile =
              widget.monsterAbilityState.drawPileContents.reversed.toList();
          var discardPile =
              widget.monsterAbilityState.discardPileContents.toList();

          final screenSize = MediaQuery.of(context).size;

          return Container(
              constraints: BoxConstraints(
                  maxWidth: screenSize.width,
                  maxHeight: screenSize.height * _kMaxHeightRatio),
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
                          child: Column(children: [
                            SizedBox(
                                width: screenSize.width,
                                child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    runSpacing: 0,
                                    spacing: 0,
                                    children: [
                                      const Text(
                                        "  Reveal\n    cards:",
                                      ),
                                      ...List.generate(
                                        min(drawPile.length,
                                            _kMaxRevealButtons),
                                        (i) => buildRevealButton(
                                            drawPile.length, i + 1),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              DrawAbilityCardCommand(
                                                  widget.monsterData.id));
                                        },
                                        child: const Text(
                                          "Draw extra card",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              ShuffleAbilityCardCommand(
                                                  widget.monsterData.id));
                                          markAsOpen(0);
                                        },
                                        child: const Text(
                                          "Extra Shuffle",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _gameState.action(
                                              ActivateMonsterTypeCommand(
                                                  widget.monsterData.id,
                                                  !widget.monsterData.isActive,
                                                  gameState: _gameState));
                                        },
                                        child: Text(
                                          widget.monsterData.isActive
                                              ? "Inactivate\nMonster"
                                              : "Activate\nMonster",
                                        ),
                                      ),
                                    ])),
                          ])),
                      Flexible(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildList(drawPile, true, false),
                          buildList(discardPile, false, true)
                        ],
                      )),
                      Container(
                        height: _kBarSize,
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                      )
                    ]),
                    Positioned(
                        width: kCloseButtonWidth,
                        height: kButtonSize,
                        right: 0,
                        bottom: 0,
                        child: TextButton(
                            child: const Text(
                              'Close',
                              style: kButtonLabelStyle,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                  ])));
        });
  }
}

class Item extends StatelessWidget {
  static const double _kScaleCardHeight = 40.0;
  static const int _kScaleCardRows = 14;
  static const double _kScaleMin = 0.5;
  static const double _kListWidthRatio = 0.4;
  static const double _kCardWidth = 142.4;

  const Item(
      {super.key,
      required this.data,
      required this.revealed,
      required this.monsterData});

  final MonsterAbilityCardModel data;
  final Monster monsterData;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = max(
        (screenSize.height / (_kScaleCardHeight * _kScaleCardRows)),
        _kScaleMin);
    if (screenSize.width * _kListWidthRatio < _kCardWidth * scale) {
      scale = screenSize.width * _kListWidthRatio / _kCardWidth;
    }

    return revealed
        ? MonsterAbilityCardFront(
            card: data, data: monsterData, scale: scale, calculateAll: true)
        : MonsterAbilityCardRear(scale: scale, size: -1, monster: monsterData);
  }
}
