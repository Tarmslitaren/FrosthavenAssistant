import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/game_data.dart';
import '../Resource/settings.dart';

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({super.key, required this.name});

  final String name;

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  final Settings settings = getIt<Settings>();

  bool _animationsEnabled = false;

  void _modelDataListener() {
    setState(() {});
  }

  @override
  void dispose() {
    _gameData.modelData.removeListener(_modelDataListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //to load save state
    _gameData.modelData.addListener(_modelDataListener);
    _animationsEnabled = initAnimationEnabled();
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value), child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value), child: child);
    }
    return Container(
        key: key,
        child: TranslationAnimatedWidget(
            //curve: Curves.slowMiddle,
            animationFinished: (bool finished) {
              if (finished) {
                _animationsEnabled = false;
              }
            },
            duration: const Duration(milliseconds: cardAnimationDuration),
            enabled: true,
            curve: Curves.easeIn,
            values: [
              const Offset(0, 0), //left to draw pile
              const Offset(0, 0), //left to draw pile
              Offset(33.3333 * settings.userScalingBars.value, 0), //end
            ],
            child: RotationAnimatedWidget(
                enabled: true,
                values: [
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: 0),
                ],
                duration: const Duration(milliseconds: cardAnimationDuration),
                child: child)));
  }

  static const int cardAnimationDuration = 1200;

  bool initAnimationEnabled() {
    if (getIt<Settings>().client.value == ClientState.connected) {
      return true; //TODO: instead of looking at nonexistent commandDescriptions, look at last gameState
    }

    if (getIt<Settings>().server.value && getIt<GameState>().commandIndex.value >= 0) {
      final int commandIndex = getIt<GameState>().commandIndex.value;
      if (commandIndex < 0) {
        return false;
      }
      if (getIt<GameState>().commandDescriptions.length > commandIndex) {
        String commandDescription = getIt<GameState>().commandDescriptions[commandIndex];
        //todo: also: missing info. need to check for updateForUndo
        if (widget.name == "allies") {
          if (commandDescription.contains("allies modifier card")) {
            return true;
          }
        } else {
          if (commandDescription.contains("monster modifier card")) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 58.6666 * settings.userScalingBars.value;
    double height = 39 * settings.userScalingBars.value;

    var screenSize = MediaQuery.of(context).size;
    double xOffset = -(screenSize.width / 2 -
        63 * settings.userScalingBars.value); //TODO: tweak to be exactly center
    double yOffset = -(screenSize.height / 2 -
        height / 2); //TODO: not correct depending on position of the deck widget

    if (!_animationsEnabled) {
      return Container(child: child);
    }

    return Container(
        key: key,
        //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: _animationsEnabled
            ? TranslationAnimatedWidget(
                animationFinished: (bool finished) {
                  if (finished) {
                    _animationsEnabled = false;
                  }
                },
                duration: const Duration(milliseconds: cardAnimationDuration),
                enabled: true,
                values: [
                  Offset(-(width + 2 * settings.userScalingBars.value), 0),
                  //left to draw pile
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
                    duration: const Duration(milliseconds: cardAnimationDuration),
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
                        duration: Duration(milliseconds: (cardAnimationDuration * 0.25).ceil()),
                        child: child)))
            : child);
  }

  @override
  Widget build(BuildContext context) {
    ModifierDeck deck = _gameState.modifierDeck;
    if (widget.name == "allies") {
      deck = _gameState.modifierDeckAllies;
    }

    bool isAnimating = false; //is not doing anything now. in case flip animation is added
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          return SizedBox(
            width: 153 * settings.userScalingBars.value,
            height: 39 * settings.userScalingBars.value,
            child: ValueListenableBuilder<int>(
                valueListenable: _gameState.commandIndex, //blanket
                builder: (context, value, child) {
                  if (_animationsEnabled != true) {
                    _animationsEnabled = initAnimationEnabled();
                  }

                  return Row(
                    children: [
                      //Material(
                      //   color: Colors.transparent,
                      //child:
                      /* InkWell(
                        focusColor: Colors.red,
                          onTap: () {
                            setState(() {
                              _animationsEnabled = true;
                              _gameState
                                  .action(DrawModifierCardCommand(widget.name));
                            });
                          },
                          child: */
                      Stack(children: [
                        deck.drawPile.isNotEmpty
                            ? Stack(children: [
                                ModifierCardWidget(
                                    card: deck.drawPile.peek,
                                    name: deck.name,
                                    revealed: isAnimating),
                                Positioned.fill(
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            focusColor: const Color(0x44000000),
                                            onTap: () {
                                              setState(() {
                                                _animationsEnabled = true;
                                                _gameState
                                                    .action(DrawModifierCardCommand(widget.name));
                                              });
                                            })))
                              ])
                            : Stack(children: [
                                Container(
                                    width: 58.6666 * settings.userScalingBars.value,
                                    height: 39 * settings.userScalingBars.value,
                                    color: Color(int.parse("7A000000", radix: 16))),
                                Positioned.fill(
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            focusColor: const Color(0x44000000),
                                            onTap: () {
                                              setState(() {
                                                _animationsEnabled = true;
                                                _gameState
                                                    .action(DrawModifierCardCommand(widget.name));
                                              });
                                            })))
                              ]),
                        Positioned(
                            bottom: 0,
                            right: 2 * settings.userScalingBars.value,
                            child: Text(
                              deck.cardCount.value.toString(),
                              style: TextStyle(
                                  fontSize: 12 * settings.userScalingBars.value,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1 * settings.userScalingBars.value,
                                            1 * settings.userScalingBars.value),
                                        color: Colors.black)
                                  ]),
                            )),
                      ]),
                      SizedBox(
                        width: 2 * settings.userScalingBars.value,
                      ),
                      Stack(children: [
                        deck.discardPile.size() > 2
                            ? buildStayAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: deck.discardPile
                                          .getList()[deck.discardPile.getList().length - 3],
                                      revealed: true,
                                    )),
                              )
                            : Container(),
                        deck.discardPile.size() > 1
                            ? buildSlideAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: deck.discardPile
                                          .getList()[deck.discardPile.getList().length - 2],
                                      revealed: true,
                                    )),
                                Key(deck.discardPile.size().toString()))
                            : Container(),
                        deck.discardPile.isNotEmpty
                            ? buildDrawAnimation(
                                ModifierCardWidget(
                                  name: deck.name,
                                  key: Key(deck.discardPile.size().toString()),
                                  card: deck.discardPile.peek,
                                  revealed: true,
                                ),
                                Key((-deck.discardPile.size()).toString()))
                            : SizedBox(
                                width: 66.6666 * settings.userScalingBars.value,
                                height: 39 * settings.userScalingBars.value,
                              ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    focusColor: const Color(0x44000000),
                                    onTap: () {
                                      setState(() {
                                        openDialog(context, ModifierCardMenu(name: deck.name));
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
