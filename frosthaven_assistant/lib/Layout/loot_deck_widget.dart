import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/view_models/loot_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';

import 'loot_card.dart';

class LootDeckWidget extends StatefulWidget {
  const LootDeckWidget({
    super.key,
    this.gameState,
    this.gameData,
    this.settings,
    this.communication,
  });

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;
  // injected for testing
  final Communication? communication;

  @override
  LootDeckWidgetState createState() => LootDeckWidgetState();
}

class LootDeckWidgetState extends State<LootDeckWidget> {
  static const double cardWidth = 13.3333;
  static const int cardAnimationDuration = 1600;

  late final LootDeckViewModel _vm;
  bool _animationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _vm = LootDeckViewModel(
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings,
      communication: widget.communication,
    );
  }

  Widget _buildStayAnimation(Widget child, double userScalingBars) {
    return Container(
        margin: EdgeInsets.only(left: cardWidth * userScalingBars),
        child: child);
  }

  Widget _buildSlideAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(left: cardWidth * userScalingBars),
          child: child);
    }
    return Container(
        key: key,
        child: RepaintBoundary(
            child: TranslationAnimatedWidget(
                animationFinished: (bool finished) {
                  if (finished) {
                    setState(() {
                      _animationsEnabled = false;
                    });
                  }
                },
                duration: const Duration(milliseconds: cardAnimationDuration),
                enabled: true,
                curve: Curves.easeIn,
                values: [
                  const Offset(0, 0),
                  const Offset(0, 0),
                  Offset(cardWidth * userScalingBars, 0),
                ],
                child: RotationAnimatedWidget(
                    enabled: true,
                    values: [
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: 0),
                    ],
                    duration:
                        const Duration(milliseconds: cardAnimationDuration),
                    child: child))));
  }

  Widget _buildDrawAnimation(
      Widget child, Key key, BuildContext context, double userScalingBars) {
    double width = 40 * userScalingBars;
    double height = 58.6666 * userScalingBars;
    double startXOffset = -(width);

    final globalPaintBounds = context.globalPaintBounds;
    Offset screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset(0, 0);
    var screenSpaceY = screenSpaceOffset.dy;
    var screenSpaceX = screenSpaceOffset.dx - startXOffset;

    const double maxScale = 4;
    var screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    var localScreenWidth = screenWidth - screenSpaceX * 2;
    var heightShaveOff = (screenSize.height - screenSpaceY) * 2;
    var localScreenHeight = screenSize.height - heightShaveOff;
    double yOffset = -(localScreenHeight / 2 + height / 2);
    double halfBigCardWidth = width / 2;
    double xOffset = (localScreenWidth) / 2 - halfBigCardWidth;

    return Container(
        key: key,
        child: _animationsEnabled
            ? RepaintBoundary(
                child: TranslationAnimatedWidget(
                    animationFinished: (bool finished) {
                      if (finished) {
                        setState(() {
                          _animationsEnabled = false;
                        });
                      }
                    },
                    duration: Duration(
                        milliseconds:
                            _animationsEnabled ? cardAnimationDuration : 0),
                    enabled: _animationsEnabled,
                    values: [
                      Offset(startXOffset, 0),
                      Offset(xOffset, yOffset),
                      Offset(xOffset, yOffset),
                      Offset(xOffset, yOffset),
                      const Offset(0, 0),
                    ],
                    child: ScaleAnimatedWidget(
                        enabled: true,
                        duration:
                            const Duration(milliseconds: cardAnimationDuration),
                        values: const [1, maxScale, maxScale, maxScale, 1],
                        child: RotationAnimatedWidget(
                            enabled: true,
                            values: [
                              Rotation.deg(x: 0, y: 0, z: 180),
                              Rotation.deg(x: 0, y: 0, z: 360),
                            ],
                            duration: Duration(
                                milliseconds:
                                    (cardAnimationDuration * 0.25).ceil()),
                            child: child))))
            : child);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Object>(
        valueListenable: _vm.modelData,
        builder: (context, value, child) {
          return _buildContent(context);
        });
  }

  Widget _buildContent(BuildContext context) {
    bool isAnimating = false;
    //is not doing anything now. in case flip animation is added

    return ValueListenableBuilder<double>(
        valueListenable: _vm.userScalingBars,
        builder: (context, value, child) {
          final userScalingBars = _vm.userScalingBars.value;
          return SizedBox(
            width: 94 * userScalingBars,
            height: 58.6666 * userScalingBars,
            child: ValueListenableBuilder<int>(
                valueListenable: _vm.commandIndex,
                builder: (context, value, child) {
                  return ValueListenableBuilder<int>(
                      valueListenable: _vm.cardCount,
                      builder: (context, value, child) {
                        if (_vm.shouldHide) {
                          return Container();
                        }

                        if (!_animationsEnabled) {
                          _animationsEnabled = _vm.initAnimationEnabled();
                        }

                        final deck = _vm.lootDeck;
                        final currentCharacterColor =
                            _vm.currentCharacterColor;
                        final currentCharacterName = _vm.currentCharacterName;
                        final discardPileSize = deck.discardPileSize;
                        final discardPileList =
                            deck.discardPileContents.toList();

                        return RepaintBoundary(
                            child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  if (deck.drawPileIsNotEmpty) {
                                    setState(() {
                                      _animationsEnabled = true;
                                      _vm.drawCard();
                                    });
                                  }
                                },
                                child: Stack(children: [
                                  deck.drawPileIsNotEmpty
                                      ? LootCardWidget(
                                          card: deck.drawPileTop,
                                          revealed: isAnimating)
                                      : Container(
                                          width: 40 * userScalingBars,
                                          height: 58.6666 * userScalingBars,
                                          color: Color(int.parse("7A000000",
                                              radix: 16))),
                                  Positioned(
                                      bottom: 0,
                                      right: 2 * userScalingBars,
                                      child: Text(
                                        deck.cardCount.value.toString(),
                                        style: TextStyle(
                                            fontSize: 12 * userScalingBars,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  offset: Offset(
                                                      1 * userScalingBars,
                                                      1 * userScalingBars),
                                                  color: Colors.black)
                                            ]),
                                      )),
                                  if (currentCharacterName != null)
                                    Positioned(
                                      height: 35 * userScalingBars,
                                      width: 35 * userScalingBars,
                                      top: 24 * userScalingBars / 2,
                                      left: 2 * userScalingBars,
                                      child: Image(
                                        color: currentCharacterColor,
                                        image: AssetImage(
                                            'assets/images/class-icons/$currentCharacterName.png'),
                                      ),
                                    )
                                ])),
                            SizedBox(
                              width: 2 * userScalingBars,
                            ),
                            InkWell(
                                onTap: () {
                                  _vm.openLootMenu(context);
                                },
                                child: Stack(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 1 * userScalingBars),
                                    width: 39 * userScalingBars,
                                    height: 57.6666 * userScalingBars,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5 * userScalingBars)),
                                      border: Border.all(color: Colors.white70),
                                      color: Color(
                                          int.parse("7A000000", radix: 16)),
                                    ),
                                  ),
                                  discardPileSize > 2
                                      ? _buildStayAnimation(
                                          RotationTransition(
                                              turns:
                                                  const AlwaysStoppedAnimation(
                                                      15 / 360),
                                              child: LootCardWidget(
                                                card: discardPileList[
                                                    discardPileSize - 3],
                                                revealed: true,
                                              )),
                                          userScalingBars)
                                      : Container(),
                                  discardPileSize > 1
                                      ? _buildSlideAnimation(
                                          RotationTransition(
                                              turns:
                                                  const AlwaysStoppedAnimation(
                                                      15 / 360),
                                              child: LootCardWidget(
                                                card: discardPileList[
                                                    discardPileSize - 2],
                                                revealed: true,
                                              )),
                                          Key(deck.discardPileSize.toString()),
                                          userScalingBars)
                                      : Container(),
                                  deck.discardPileIsNotEmpty
                                      ? _buildDrawAnimation(
                                          LootCardWidget(
                                            key:
                                                Key(discardPileSize.toString()),
                                            card: deck.discardPileTop,
                                            revealed: true,
                                          ),
                                          Key((-deck.discardPileSize)
                                              .toString()),
                                          context,
                                          userScalingBars)
                                      : SizedBox(
                                          width: 40 * userScalingBars,
                                          height: 58.6666 * userScalingBars,
                                        ),
                                ]))
                          ],
                        ));
                      });
                }),
          );
        });
  }
}
