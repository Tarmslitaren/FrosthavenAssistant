import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Layout/view_models/modifier_deck_view_model.dart';
import 'package:frosthaven_assistant/Resource/game_data.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/network/communication.dart';

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({
    super.key,
    required this.name,
    this.gameState,
    this.gameData,
    this.settings,
    this.communication,
  });

  final String name;

  final GameState? gameState;
  final GameData? gameData;
  final Settings? settings;
  // injected for testing
  final Communication? communication;

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  static const int cardAnimationDuration = 1200;

  late final ModifierDeckViewModel _vm;
  bool _animationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _vm = ModifierDeckViewModel(
      widget.name,
      gameState: widget.gameState,
      gameData: widget.gameData,
      settings: widget.settings,
      communication: widget.communication,
    );
  }

  Widget _buildStayAnimation(Widget child, double userScalingBars) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333 * userScalingBars),
        child: child);
  }

  Widget _buildSlideAnimation(Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(left: 33.3333 * userScalingBars),
          child: child);
    }
    return Container(
        key: key,
        child: RepaintBoundary(
            child: TranslationAnimatedWidget(
                animationFinished: (bool finished) {
                  if (finished) {
                    _animationsEnabled = false;
                  }
                },
                duration: const Duration(milliseconds: cardAnimationDuration),
                enabled: true,
                curve: Curves.easeIn,
                values: [
                  const Offset(0, 0),
                  const Offset(0, 0),
                  Offset(33.3333 * userScalingBars, 0),
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
      Widget child, Key key, double userScalingBars) {
    if (!_animationsEnabled || context.globalPaintBounds == null) {
      return Container(child: child);
    }
    double width = 58.6666 * userScalingBars;
    double height = 39 * userScalingBars;
    var screenSize = MediaQuery.of(context).size;
    double startXOffset = -(width + 2 * userScalingBars);

    final globalPaintBounds = context.globalPaintBounds;
    Offset screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset(0, 0);
    var screenSpaceY = screenSpaceOffset.dy;
    var screenSpaceX = screenSpaceOffset.dx - startXOffset;

    const double maxScale = 4;
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
                        _animationsEnabled = false;
                      }
                    },
                    duration:
                        const Duration(milliseconds: cardAnimationDuration),
                    enabled: true,
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
            width: 153 * userScalingBars,
            height: 39 * userScalingBars,
            child: ValueListenableBuilder<int>(
                valueListenable: _vm.commandIndex,
                builder: (context, value, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = _vm.initAnimationEnabled();
                  }

                  final textStyle = TextStyle(
                      fontSize: 12 * userScalingBars,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(
                                1 * userScalingBars, 1 * userScalingBars),
                            color: Colors.black)
                      ]);

                  final currentCharacterColor = _vm.currentCharacterColor;
                  final currentCharacterName = _vm.currentCharacterName;
                  final deck = _vm.deck;
                  final discardPileSize = deck.discardPileSize;
                  final discardPileList = deck.discardPileContents.toList();
                  final widgetKey = discardPileSize.toString();

                  final characterIconWidget = Positioned(
                    height: 27 * userScalingBars,
                    width: 27 * userScalingBars,
                    top: 12 * userScalingBars / 2,
                    left: 16 * userScalingBars,
                    child: Image.asset(
                        color: currentCharacterColor,
                        'assets/images/class-icons/$currentCharacterName.png'),
                  );

                  return Row(
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              _animationsEnabled = true;
                              _vm.drawCard();
                            });
                          },
                          child: Stack(children: [
                            deck.drawPileIsNotEmpty
                                ? Stack(children: [
                                    ModifierCardWidget(
                                        card: deck.drawPileTop,
                                        name: deck.name,
                                        revealed: isAnimating ||
                                            deck.revealedCount.value > 0),
                                    Positioned.fill(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                                focusColor:
                                                    const Color(0x44000000),
                                                onTap: () {
                                                  setState(() {
                                                    _animationsEnabled = true;
                                                    _vm.drawCard();
                                                  });
                                                })))
                                  ])
                                : Stack(children: [
                                    Container(
                                        width: 58.6666 * userScalingBars,
                                        height: 39 * userScalingBars,
                                        color: Color(
                                            int.parse("7A000000", radix: 16))),
                                    if (currentCharacterName != null)
                                      characterIconWidget,
                                    Positioned.fill(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              focusColor:
                                                  const Color(0x44000000),
                                              onTap: () {
                                                setState(() {
                                                  _animationsEnabled = true;
                                                  _vm.drawCard();
                                                });
                                              },
                                              child: Center(
                                                  child: Text(
                                                "Shuffle\n& Draw",
                                                style: textStyle,
                                                textAlign: TextAlign.center,
                                              )),
                                            )))
                                  ]),
                            Positioned(
                                bottom: 0,
                                right: 2 * userScalingBars,
                                child: Text(
                                  deck.cardCount.value.toString(),
                                  style: textStyle,
                                )),
                          ])),
                      SizedBox(
                        width: 2 * userScalingBars,
                      ),
                      Stack(children: [
                        Container(
                          margin: EdgeInsets.only(top: 1 * userScalingBars),
                          width: 57.6666 * userScalingBars,
                          height: 39 * userScalingBars,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5 * userScalingBars)),
                            border: Border.all(color: Colors.white70),
                            color: Color(int.parse("7A000000", radix: 16)),
                          ),
                        ),
                        discardPileSize > 2
                            ? _buildStayAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - 3],
                                      revealed: true,
                                    )),
                                userScalingBars)
                            : Container(),
                        discardPileSize > 1
                            ? _buildSlideAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - 2],
                                      revealed: true,
                                    )),
                                Key(widgetKey),
                                userScalingBars)
                            : Container(),
                        deck.discardPileIsNotEmpty
                            ? _buildDrawAnimation(
                                ModifierCardWidget(
                                  name: deck.name,
                                  key: Key(widgetKey),
                                  card: deck.discardPileTop,
                                  revealed: true,
                                ),
                                Key((-deck.discardPileSize).toString()),
                                userScalingBars)
                            : SizedBox(
                                width: 66.6666 * userScalingBars,
                                height: 39 * userScalingBars,
                              ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    focusColor: const Color(0x44000000),
                                    onLongPress: () {
                                      _vm.openZoom(context);
                                    },
                                    onTap: () {
                                      setState(() {
                                        _vm.openModifierMenu(context);
                                      });
                                    })))
                      ])
                    ],
                  );
                }),
          );
        });
  }
}
