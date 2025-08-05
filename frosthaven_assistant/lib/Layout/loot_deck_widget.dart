import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/network/network.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/commands/draw_loot_card_command.dart';
import '../Resource/game_data.dart';
import '../Resource/settings.dart';
import 'loot_card.dart';
import 'menus/loot_cards_menu.dart';

class LootDeckWidget extends StatefulWidget {
  const LootDeckWidget({super.key});

  @override
  LootDeckWidgetState createState() => LootDeckWidgetState();
}

class LootDeckWidgetState extends State<LootDeckWidget> {
  final GameState _gameState = getIt<GameState>();
  final GameData _gameData = getIt<GameData>();
  final Settings _settings = getIt<Settings>();
  static const double cardWidth = 13.3333;
  static const int cardAnimationDuration = 1600;

  bool _animationsEnabled = false;

  void _modelDataListenerLootDeck() {
    setState(() {});
  }

  @override
  void dispose() {
    _gameData.modelData.removeListener(_modelDataListenerLootDeck);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //to load save state
    _gameData.modelData.addListener(_modelDataListenerLootDeck);
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin:
            EdgeInsets.only(left: cardWidth * _settings.userScalingBars.value),
        child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!_animationsEnabled) {
      return Container(
          margin: EdgeInsets.only(
              left: cardWidth * _settings.userScalingBars.value),
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
              Offset(cardWidth * _settings.userScalingBars.value, 0), //end
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
    if (getIt<Settings>().client.value == ClientState.connected ||
        getIt<Settings>().server.value) {
      GameState oldState = GameState();
      int offset = 1;
      if (_gameState.gameSaveStates.length <= offset ||
          _gameState
                  .gameSaveStates[_gameState.gameSaveStates.length - offset] ==
              null) {
        return false;
      }

      String oldSave = _gameState
          .gameSaveStates[_gameState.gameSaveStates.length - offset]!
          .getState();
      oldState.loadFromData(oldSave);
      GameState currentState = _gameState;

      var oldPile = oldState.lootDeck.discardPile;
      var newPile = currentState.lootDeck.discardPile;
      if (oldPile.size() == newPile.size() - 1) {
        return true;
      }
      return false;
    }
    return false;
  }

  Widget buildDrawAnimation(Widget child, Key key, BuildContext context) {
    double width = 40 * _settings.userScalingBars.value; //the width of a card
    double height = 58.6666 * _settings.userScalingBars.value;
    double startXOffset = -(width);

    Offset screenSpaceOffset = context.globalPaintBounds != null
        ? context.globalPaintBounds!.topLeft
        : Offset(0, 0);
    var screenSpaceY =
        screenSpaceOffset.dy; //draw deck top position from screen top
    var screenSpaceX = screenSpaceOffset.dx -
        startXOffset; //draw deck left position from screen left

    //compose a translation, scale, rotation
    const double maxScale = 4; //how big card is in center
    var screenSize = MediaQuery.of(context).size;
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
                duration: Duration(
                    milliseconds:
                        _animationsEnabled ? cardAnimationDuration : 0),
                enabled: _animationsEnabled,
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
                          Rotation.deg(x: 0, y: 0, z: 180),
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
    bool isAnimating = false;
    //is not doing anything now. in case flip animation is added

    return ValueListenableBuilder<double>(
        valueListenable: _settings.userScalingBars,
        builder: (context, value, child) {
          return SizedBox(
            width: 94 * _settings.userScalingBars.value,
            height: 58.6666 * _settings.userScalingBars.value,
            child: ValueListenableBuilder<int>(
                valueListenable: _gameState.commandIndex,
                builder: (context, value, child) {
                  return ValueListenableBuilder<int>(
                      valueListenable: _gameState.lootDeck.cardCount,
                      builder: (context, value, child) {
                        LootDeck? deck = _gameState.lootDeck;
                        if (deck.drawPile.isEmpty && deck.discardPile.isEmpty ||
                            getIt<Settings>().hideLootDeck.value == true) {
                          return Container();
                        }

                        if (_animationsEnabled != true) {
                          _animationsEnabled = initAnimationEnabled();
                        }

                        Color currentCharacterColor = Colors.transparent;
                        String? currentCharacterName;
                        for (var item in _gameState.currentList) {
                          if (item.turnState.value == TurnsState.current) {
                            if (item is Character) {
                              if (!GameMethods.isObjectiveOrEscort(
                                  item.characterClass)) {
                                currentCharacterColor = Colors.black;
                                currentCharacterName = item.characterClass.name;
                              }
                            }
                          }
                        }

                        var userScalingBars = _settings.userScalingBars.value;

                        return Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  if (deck.drawPile.isNotEmpty) {
                                    setState(() {
                                      _animationsEnabled = true;
                                      _gameState.action(DrawLootCardCommand());
                                    });
                                  }
                                },
                                child: Stack(children: [
                                  deck.drawPile.isNotEmpty
                                      ? LootCardWidget(
                                          card: deck.drawPile.peek,
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
                                      child: Image.asset(
                                          color: currentCharacterColor,
                                          'assets/images/class-icons/$currentCharacterName.png'),
                                    )
                                ])),
                            SizedBox(
                              width: 2 * userScalingBars,
                            ),
                            InkWell(
                                onTap: () {
                                  openDialog(context, const LootCardMenu());
                                },
                                child: Stack(children: [
                                  deck.discardPile.size() > 2
                                      ? buildStayAnimation(
                                          RotationTransition(
                                              turns:
                                                  const AlwaysStoppedAnimation(
                                                      15 / 360),
                                              child: LootCardWidget(
                                                card: deck.discardPile
                                                    .getList()[deck.discardPile
                                                        .getList()
                                                        .length -
                                                    3],
                                                revealed: true,
                                              )),
                                        )
                                      : Container(),
                                  deck.discardPile.size() > 1
                                      ? buildSlideAnimation(
                                          RotationTransition(
                                              turns:
                                                  const AlwaysStoppedAnimation(
                                                      15 / 360),
                                              child: LootCardWidget(
                                                card: deck.discardPile
                                                    .getList()[deck.discardPile
                                                        .getList()
                                                        .length -
                                                    2],
                                                revealed: true,
                                              )),
                                          Key(deck.discardPile
                                              .size()
                                              .toString()))
                                      : Container(),
                                  deck.discardPile.isNotEmpty
                                      ? buildDrawAnimation(
                                          LootCardWidget(
                                            key: Key(deck.discardPile
                                                .size()
                                                .toString()),
                                            card: deck.discardPile.peek,
                                            revealed: true,
                                          ),
                                          Key((-deck.discardPile.size())
                                              .toString()),
                                          context)
                                      : SizedBox(
                                          width: 40 * userScalingBars,
                                          height: 58.6666 * userScalingBars,
                                        ),
                                ]))
                          ],
                        );
                      });
                }),
          );
        });
  }
}
