import 'dart:math';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';

double smallify = 0.66666;

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({Key? key}) : super(key: key);

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
  }
  Widget buildSlideAnimation(Widget child, Key key) {
    return Container(
        key: key,
        child: TranslationAnimatedWidget(
          //curve: Curves.slowMiddle,
          /*animationFinished: (bool finished){
            if (finished) {
              //enabled = false;
            }
          },*/
            duration: Duration(milliseconds: cardAnimationDuration),
            enabled: enabled,
            curve: Curves.easeIn,
            values: [
              Offset(0, 0), //left to drawpile
              Offset(0, 0), //left to drawpile
              Offset(50*smallify, 0), //end
            ],
                child: RotationAnimatedWidget(
                    enabled: enabled,
                    values: [
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: 0),
                    ],
                    duration: Duration(milliseconds:cardAnimationDuration),
                    child: child)));

  }

  static int cardAnimationDuration = 1200;
  bool enabled = true; //TODO: disable the animation onc eit is done and save the disabled state, so it doesn't play on resize/restart
  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 88 * smallify;
    double height = 40;
    //enabled = !enabled; //testing

    var screenSize = MediaQuery.of(context).size;
    double xOffset = -(screenSize.width/2 - 100*smallify);
    double yOffset = -(screenSize.height/2 - height/2);

    return Container(
      key: key, //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: TranslationAnimatedWidget(
          //curve: Curves.slowMiddle,
          /*animationFinished: (bool finished){
            if (finished) {
              //enabled = false;
            }
          },*/
        duration: Duration(milliseconds: cardAnimationDuration),
        enabled: enabled,
        values: [
          Offset(-(width+2), 0), //left to drawpile
          Offset(xOffset, yOffset), //center of screen
          Offset(xOffset, yOffset), //center of screen
          Offset(xOffset, yOffset), //center of screen
          Offset(0, 0), //end
        ],
        child: ScaleAnimatedWidget( //does nothing
          enabled: enabled,
            duration: Duration(milliseconds: cardAnimationDuration),

            values: [
              1,
              4,
              4,
              4,
              1
            ],
            child: RotationAnimatedWidget(
              enabled: enabled,
               values: [
                 //Rotation.deg(x: 0, y: 0, z: 0),
                 //Rotation.deg(x:0, y: 0, z: 90),
                 Rotation.deg(x: 0, y: 0, z: 180),
                 //Rotation.deg(x: 0, y: 0, z: 270),
                 Rotation.deg(x: 0, y: 0, z: 360),
               ],
               duration: Duration(milliseconds:(cardAnimationDuration * 0.25).ceil()),
                child: child))));
  }

  @override
  Widget build(BuildContext context) {
    bool isAnimating = false;
    return Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: 230 * smallify,
          height: 40,
          child: ValueListenableBuilder<int>(
              valueListenable: _gameState.modifierDeck.curses,
              builder: (context, value, child) {
                return Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _gameState.action(DrawModifierCardCommand());
                          });
                        },
                        child: Stack(children: [
                          _gameState.modifierDeck.drawPile.isNotEmpty
                              ? ModifierCardWidget(
                                  card: _gameState.modifierDeck.drawPile.peek,
                                  revealed: isAnimating)
                              : Container(
                                  width: 88 * smallify,
                                  height: 40,
                                  color:
                                      Color(int.parse("7A000000", radix: 16))),
                          Positioned(
                              bottom: 0,
                              right: 2,
                              child: Text(
                                _gameState.modifierDeck.cardCount.value
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          offset: Offset(1, 1),
                                          color: Colors.black)
                                    ]),
                              ))
                        ])),
                    SizedBox(
                      width: 2,
                    ),
                    GestureDetector(
                        onTap: () {
                          openDialog(context, const ModifierCardMenu());
                        },
                        child: Container(
                            width: 105 * smallify, //155
                            child: Stack(children: [
                              _gameState.modifierDeck.discardPile.size() > 1
                                  ? buildSlideAnimation(Container(
                                      //left: 55 * smallify,
                                      child: RotationTransition(
                                          turns: const AlwaysStoppedAnimation(
                                              15 / 360),
                                          child:

                                              //Transform.rotate(angle: - pi / 4, child:
                                              ModifierCardWidget(
                                            card: _gameState
                                                .modifierDeck.discardPile
                                                .getList()[_gameState
                                                    .modifierDeck.discardPile
                                                    .getList()
                                                    .length -
                                                2],
                                            revealed: true,
                                          ))), Key(_gameState.modifierDeck.discardPile.size().toString()))
                                  : Container(),
                              _gameState.modifierDeck.discardPile.isNotEmpty
                                  ? buildDrawAnimation(
                                  ModifierCardWidget(
                                key: Key(_gameState.modifierDeck.discardPile.size().toString()),
                                      card: _gameState
                                          .modifierDeck.discardPile.peek,
                                      revealed: true,
                                    ),
                                Key((-_gameState.modifierDeck.discardPile.size()).toString()))
                                  : Container(
                                      width: 100 * smallify,
                                      height: 40,
                                    ),
                            ])))
                  ],
                );
              }),
        ));
  }
}
