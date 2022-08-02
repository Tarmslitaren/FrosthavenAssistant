import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/action_handler.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/settings.dart';

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({Key? key}) : super(key: key);

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  final GameState _gameState = getIt<GameState>();
  final Settings settings = getIt<Settings>();

  @override
  void initState() {
    super.initState();

    //to load save state
    _gameState.modelData.addListener(() {
      setState(() {});
    });
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
        child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!animationsEnabled) {
      return Container(
          margin:
              EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
          child: child);
    }
    return Container(
        key: key,
        child: TranslationAnimatedWidget(
            //curve: Curves.slowMiddle,
            animationFinished: (bool finished) {
              if (finished) {
                animationsEnabled = false;
              }
            },
            duration: Duration(milliseconds: cardAnimationDuration),
            enabled: true,
            curve: Curves.easeIn,
            values: [
              const Offset(0, 0), //left to drawpile
              const Offset(0, 0), //left to drawpile
              Offset(33.3333 * settings.userScalingBars.value, 0), //end
            ],
            child: RotationAnimatedWidget(
                enabled: true,
                values: [
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: 0),
                ],
                duration: Duration(milliseconds: cardAnimationDuration),
                child: child)));
  }

  static int cardAnimationDuration = 1200;
  bool animationsEnabled = false;

  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 58.6666 * settings.userScalingBars.value;
    double height = 40 * settings.userScalingBars.value;

    var screenSize = MediaQuery.of(context).size;
    double xOffset =
        -(screenSize.width / 2 - 66.6666 * settings.userScalingBars.value);
    double yOffset = -(screenSize.height / 2 - height / 2);

    return Container(
        key: key,
        //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: animationsEnabled
            ? TranslationAnimatedWidget(
                duration: Duration(milliseconds: cardAnimationDuration),
                enabled: true,
                values: [
                  Offset(-(width + 2 * settings.userScalingBars.value), 0),
                  //left to drawpile
                  Offset(xOffset, yOffset),
                  //center of screen
                  Offset(xOffset, yOffset),
                  //center of screen
                  Offset(xOffset, yOffset),
                  //center of screen
                  const Offset(0, 0),
                  //end
                ],
                child: ScaleAnimatedWidget(
                    //does nothing
                    enabled: true,
                    duration: Duration(milliseconds: cardAnimationDuration),
                    values: const [1, 4, 4, 4, 1],
                    child: RotationAnimatedWidget(
                        enabled: true,
                        values: [
                          //Rotation.deg(x: 0, y: 0, z: 0),
                          //Rotation.deg(x:0, y: 0, z: 90),
                          Rotation.deg(x: 0, y: 0, z: 180),
                          //Rotation.deg(x: 0, y: 0, z: 270),
                          Rotation.deg(x: 0, y: 0, z: 360),
                        ],
                        duration: Duration(
                            milliseconds:
                                (cardAnimationDuration * 0.25).ceil()),
                        child: child)))
            : child);
  }

  @override
  Widget build(BuildContext context) {
    bool isAnimating =
        false; //is not doing anything now. in case flip animation is added
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          return SizedBox(
            width: 153 * settings.userScalingBars.value,
            //TODO: make smaller if can't fit on screen?
            height: 40 * settings.userScalingBars.value,
            child: ValueListenableBuilder<int>(
                valueListenable: _gameState.commandIndex, //blanket
                builder: (context, value, child) {
                  return Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              animationsEnabled = true;
                              _gameState.action(DrawModifierCardCommand());
                            });
                          },
                          child: Stack(children: [
                            _gameState.modifierDeck.drawPile.isNotEmpty
                                ? ModifierCardWidget(
                                    card: _gameState.modifierDeck.drawPile.peek,
                                    revealed: isAnimating)
                                : Container(
                                    width: 58.6666 *
                                        settings.userScalingBars.value,
                                    height: 40 * settings.userScalingBars.value,
                                    color: Color(
                                        int.parse("7A000000", radix: 16))),
                            Positioned(
                                bottom: 0,
                                right: 2 * settings.userScalingBars.value,
                                child: Text(
                                  _gameState.modifierDeck.cardCount.value
                                      .toString(),
                                  style: TextStyle(
                                      fontSize:
                                          12 * settings.userScalingBars.value,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            offset: Offset(
                                                1 *
                                                    settings
                                                        .userScalingBars.value,
                                                1 *
                                                    settings
                                                        .userScalingBars.value),
                                            color: Colors.black)
                                      ]),
                                ))
                          ])),
                      SizedBox(
                        width: 2 * settings.userScalingBars.value,
                      ),
                      GestureDetector(
                          onTap: () {
                            openDialog(context, const ModifierCardMenu());
                          },
                          child: Container(
                              //width: 105 * smallify, //155
                              child: Stack(children: [
                            _gameState.modifierDeck.discardPile.size() > 2
                                ? buildStayAnimation(
                                    Container(
                                        //left: 55 * smallify,
                                        child: RotationTransition(
                                            turns: const AlwaysStoppedAnimation(
                                                15 / 360),
                                            child: ModifierCardWidget(
                                              card: _gameState
                                                  .modifierDeck.discardPile
                                                  .getList()[_gameState
                                                      .modifierDeck.discardPile
                                                      .getList()
                                                      .length -
                                                  3],
                                              revealed: true,
                                            ))),
                                  )
                                : Container(),
                            _gameState.modifierDeck.discardPile.size() > 1
                                ? buildSlideAnimation(
                                    RotationTransition(
                                        turns: const AlwaysStoppedAnimation(
                                            15 / 360),
                                        child: ModifierCardWidget(
                                          card: _gameState
                                              .modifierDeck.discardPile
                                              .getList()[_gameState
                                                  .modifierDeck.discardPile
                                                  .getList()
                                                  .length -
                                              2],
                                          revealed: true,
                                        )),
                                    Key(_gameState.modifierDeck.discardPile
                                        .size()
                                        .toString()))
                                : Container(),
                            _gameState.modifierDeck.discardPile.isNotEmpty
                                ? buildDrawAnimation(
                                    ModifierCardWidget(
                                      key: Key(_gameState
                                          .modifierDeck.discardPile
                                          .size()
                                          .toString()),
                                      card: _gameState
                                          .modifierDeck.discardPile.peek,
                                      revealed: true,
                                    ),
                                    Key((-_gameState.modifierDeck.discardPile
                                            .size())
                                        .toString()))
                                : Container(
                                    width: 66.6666 *
                                        settings.userScalingBars.value,
                                    height: 40 * settings.userScalingBars.value,
                                  ),
                          ])))
                    ],
                  );
                }),
          );
        });
  }
}
