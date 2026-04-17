import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/return_amd_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';

import '../../Resource/game_methods.dart';
import '../../Resource/state/game_state.dart';
import '../../Resource/ui_utils.dart';
import '../../services/service_locator.dart';

class RemovedModifierCardMenu extends StatefulWidget {
  const RemovedModifierCardMenu({
    super.key,
    required this.name,
    this.gameState,
  });

  final String name;

  final GameState? gameState;

  @override
  RemovedModifierCardMenuState createState() => RemovedModifierCardMenuState();
}

class RemovedModifierCardMenuState extends State<RemovedModifierCardMenu> {
  static const double _kListWidthRatio = 0.3;
  static const double _kMaxHeightRatio = 0.9;
  static const double _kHeaderPadding = 10.0;
  static const double _kBottomBarHeight = 32.0;
  static const double _kCloseButtonBottom = 4.0;
  static const double _kCloseButtonLeft = 20.0;
  static const double _kItemMargin = 2.0;

  late final GameState _gameState;
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
          width: screenWidth * _kListWidthRatio,
          child: ListView(
            controller: ScrollController(),
            children: generateList(list, widget.name).reversed.toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState ?? getIt<GameState>();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _gameState.commandIndex,
        builder: (context, value, child) {
          String name = widget.name;
          ModifierDeck deck =
              GameMethods.getModifierDeck(widget.name, _gameState);
          final removedPile = deck.removedPileContents.toList();
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
                          width: screenSize.width, //need some width to fill out
                          margin: const EdgeInsets.all(_kItemMargin),
                          padding: EdgeInsets.all(_kHeaderPadding),
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
                        height: _kBottomBarHeight,
                        margin: const EdgeInsets.all(_kItemMargin),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                      ),
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
                    Positioned(
                        bottom: _kCloseButtonBottom,
                        left: _kCloseButtonLeft,
                        child: Text(
                          name,
                          style: kButtonLabelStyle,
                        ))
                  ])));
        });
  }
}

class Item extends StatelessWidget {
  static const double _kScaleHeightBase = 40.0;
  static const int _kScaleHeightRows = 12;
  static const int _kBuildFrontVariant = 2;
  static const double _kItemMargin = 2.0;

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
    double scale = max((screenSize.height / (_kScaleHeightBase * _kScaleHeightRows)), 1);
    final Widget child = revealed
        ? ModifierCardWidget.buildFront(data, name, scale, _kBuildFrontVariant)
        : ModifierCardWidget.buildRear(scale, name);

    return Container(margin: EdgeInsets.all(_kItemMargin * scale), child: child);
  }
}
