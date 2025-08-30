import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card_widget.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
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
  static const int cardAnimationDuration = 1200;
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  final Settings settings = getIt<Settings>();

  bool _animationsEnabled = false;

  @override
  void initState() {
    super.initState();

    //to load save state
    _gameData.modelData.addListener(_modelDataListener);
  }

  void _modelDataListener() {
    setState(() {});
  }

  @override
  void dispose() {
    _gameData.modelData.removeListener(_modelDataListener);
    super.dispose();
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
        child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!_animationsEnabled) {
      return Container(
          margin:
              EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
          child: child);
    }
    return Container(
        key: key,
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

  bool initAnimationEnabled() {
    if (getIt<Settings>().client.value == ClientState.connected) {
      GameState oldState = GameState();
      int offset = 1;
      final saveStateLength = _gameState.gameSaveStates.length;
      final saveState = _gameState.gameSaveStates[saveStateLength - offset];
      if (saveStateLength <= offset || saveState == null) {
        return false;
      } else {
        oldState.loadFromData(saveState.getState());
      }

      GameState currentState = _gameState;

      ModifierDeck oldDeck = GameMethods.getModifierDeck(widget.name, oldState);
      ModifierDeck currentDeck =
          GameMethods.getModifierDeck(widget.name, currentState);
      var oldPile = oldDeck.discardPile;
      var newPile = currentDeck.discardPile;
      if (oldPile.size() == newPile.size() - 1) {
        return true;
      }
      return false;
    }

    final commandIndex = getIt<GameState>().commandIndex.value;
    final commandDescriptions = getIt<GameState>().commandDescriptions;
    if (getIt<Settings>().server.value && commandIndex >= 0) {
      if (commandIndex < 0) {
        return false;
      }
      if (commandDescriptions.length > commandIndex) {
        String commandDescription = commandDescriptions[commandIndex];
        if (widget.name.isNotEmpty) {
          if (commandDescription.contains("${widget.name} modifier card")) {
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
    if (!_animationsEnabled || context.globalPaintBounds == null) {
      return Container(child: child);
    }
    final userScalingBars = settings.userScalingBars.value;
    //compose a translation, scale, rotation
    double width = 58.6666 * userScalingBars;
    double height = 39 * userScalingBars;

    var screenSize = MediaQuery.of(context).size;

    double startXOffset = -(width + 2 * userScalingBars);

    final globalPaintBounds = context.globalPaintBounds;
    Offset screenSpaceOffset =
        globalPaintBounds != null ? globalPaintBounds.topLeft : Offset(0, 0);
    var screenSpaceY =
        screenSpaceOffset.dy; //draw deck top position from screen top
    var screenSpaceX = screenSpaceOffset.dx -
        startXOffset; //draw deck left position from screen left

    //compose a translation, scale, rotation
    const double maxScale = 4; //how big card is in center
    double screenWidth = screenSize.width;
    var localScreenWidth = screenWidth - screenSpaceX * 2;
    var heightShaveOff = (screenSize.height - screenSpaceY) * 2;
    var localScreenHeight = screenSize.height - heightShaveOff;
    double yOffset = -(localScreenHeight / 2 + height / 2);
    double halfBigCardWidth =
        width / 2; //lol up scaled width is same as normal width
    double xOffset = (localScreenWidth) / 2 -
        halfBigCardWidth; //is correct if max scale is 1

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
                  Offset(startXOffset, 0),
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
                    duration:
                        const Duration(milliseconds: cardAnimationDuration),
                    values: const [1, maxScale, maxScale, maxScale, 1],
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
          final userScalingBars = settings.userScalingBars.value;
          return SizedBox(
            width: 153 * userScalingBars,
            height: 39 * userScalingBars,
            child: ValueListenableBuilder<int>(
                valueListenable: _gameState.commandIndex, //blanket
                builder: (context, value, child) {
                  if (!_animationsEnabled) {
                    _animationsEnabled = initAnimationEnabled();
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

                  Color currentCharacterColor = Colors.transparent;
                  String? currentCharacterName;
                  Character? currentCharacter =
                      GameMethods.getCurrentCharacter();
                  ModifierDeck deck =
                      GameMethods.getModifierDeck(widget.name, _gameState);
                  if (currentCharacter != null &&
                      currentCharacter.id == deck.name) {
                    currentCharacterColor = Colors.black;
                    currentCharacterName = currentCharacter.characterClass.name;
                  }

                  final discardPileSize = deck.discardPile.size();
                  final discardPileList = deck.discardPile.getList();
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
                          canRequestFocus: false,
                          onTap: () {
                            setState(() {
                              _animationsEnabled = true;
                              _gameState
                                  .action(DrawModifierCardCommand(widget.name));
                            });
                          },
                          child: Stack(children: [
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
                                                canRequestFocus: false,
                                                focusColor:
                                                    const Color(0x44000000),
                                                onTap: () {
                                                  setState(() {
                                                    _animationsEnabled = true;
                                                    _gameState.action(
                                                        DrawModifierCardCommand(
                                                            widget.name));
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
                                              canRequestFocus: false,
                                              focusColor:
                                                  const Color(0x44000000),
                                              onTap: () {
                                                setState(() {
                                                  _animationsEnabled = true;
                                                  _gameState.action(
                                                      DrawModifierCardCommand(
                                                          widget.name));
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
                        discardPileSize > 2
                            ? buildStayAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - 3],
                                      revealed: true,
                                    )),
                              )
                            : Container(),
                        discardPileSize > 1
                            ? buildSlideAnimation(
                                RotationTransition(
                                    turns:
                                        const AlwaysStoppedAnimation(15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: discardPileList[
                                          discardPileList.length - 2],
                                      revealed: true,
                                    )),
                                Key(widgetKey))
                            : Container(),
                        deck.discardPile.isNotEmpty
                            ? buildDrawAnimation(
                                ModifierCardWidget(
                                  name: deck.name,
                                  key: Key(widgetKey),
                                  card: deck.discardPile.peek,
                                  revealed: true,
                                ),
                                Key((-deck.discardPile.size()).toString()))
                            : SizedBox(
                                width: 66.6666 * userScalingBars,
                                height: 39 * userScalingBars,
                              ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    canRequestFocus: false,
                                    focusColor: const Color(0x44000000),
                                    onTap: () {
                                      setState(() {
                                        openDialog(context,
                                            ModifierCardMenu(name: deck.name));
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
