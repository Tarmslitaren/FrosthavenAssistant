import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
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
  final Settings settings = getIt<Settings>();

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
        margin: EdgeInsets.only(left: 13.3333 * settings.userScalingBars.value),
        child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!animationsEnabled) {
      return Container(
          margin:
              EdgeInsets.only(left: 13.3333 * settings.userScalingBars.value),
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
            duration: const Duration(milliseconds: cardAnimationDuration),
            enabled: true,
            curve: Curves.easeIn,
            values: [
              const Offset(0, 0), //left to draw pile
              const Offset(0, 0), //left to draw pile
              Offset(13.3333 * settings.userScalingBars.value, 0), //end
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

  static const int cardAnimationDuration = 1600;

  bool animationsEnabled = initAnimationEnabled();

  static bool initAnimationEnabled() {
    if (getIt<Settings>().client.value == ClientState.connected ||
        getIt<Settings>().server.value &&
            getIt<GameState>().commandIndex.value >= 0 &&
            getIt<GameState>()
                .commandDescriptions[getIt<GameState>().commandIndex.value]
                .contains("loot card")) {
      //todo: also: missing info. need to check for updateForUndo
      return true;
    }
    return false;
  }

  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 40 * settings.userScalingBars.value;
    double height = 58.6666 * settings.userScalingBars.value;

    var screenSize = MediaQuery.of(context).size;
    double xOffset =
        (screenSize.width / 2 - 63 * settings.userScalingBars.value);
    double yOffset = -(screenSize.height / 2 - height);

    if (!animationsEnabled) {
      return Container(child: child);
    }

    return Container(
        key: key,
        //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: animationsEnabled
            ? TranslationAnimatedWidget(
                animationFinished: (bool finished) {
                  if (finished) {
                    animationsEnabled = false;
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
                    duration:
                        const Duration(milliseconds: cardAnimationDuration),
                    values: const [1, 4, 4, 4, 1],
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
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          return SizedBox(
            width: (94) * settings.userScalingBars.value,
            height: 58.6666 * settings.userScalingBars.value,
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

                        if (animationsEnabled != true) {
                          animationsEnabled = initAnimationEnabled();
                        }

                        Color currentCharacterColor = Colors.transparent;
                        String? currentCharacterName;
                        for (var item in _gameState.currentList) {
                          if (item.turnState == TurnsState.current) {
                            if (item is Character) {
                              if (item.characterClass.name != "Objective" &&
                                  item.characterClass.name != "Escort") {
                                currentCharacterColor =
                                    Colors.black; //item.characterClass.color;
                                currentCharacterName = item.characterClass.name;
                              }
                            }
                          }
                        }

                        return Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  if (deck.drawPile.isNotEmpty) {
                                    setState(() {
                                      animationsEnabled = true;
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
                                          width: 40 *
                                              settings.userScalingBars.value,
                                          height: 58.6666 *
                                              settings.userScalingBars.value,
                                          color: Color(int.parse("7A000000",
                                              radix: 16))),
                                  Positioned(
                                      bottom: 0,
                                      right: 2 * settings.userScalingBars.value,
                                      child: Text(
                                        deck.cardCount.value.toString(),
                                        style: TextStyle(
                                            fontSize: 12 *
                                                settings.userScalingBars.value,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  offset: Offset(
                                                      1 *
                                                          settings
                                                              .userScalingBars
                                                              .value,
                                                      1 *
                                                          settings
                                                              .userScalingBars
                                                              .value),
                                                  color: Colors.black)
                                            ]),
                                      )),
                                  if (currentCharacterName != null)
                                    Positioned(
                                      height:
                                          35 * settings.userScalingBars.value,
                                      width:
                                          35 * settings.userScalingBars.value,
                                      top: 24 *
                                          settings.userScalingBars.value /
                                          2,
                                      left: 2 * settings.userScalingBars.value,
                                      child: Image.asset(
                                          // fit: BoxFit.fitWidth,
                                          color: currentCharacterColor,
                                          'assets/images/class-icons/$currentCharacterName.png'),
                                    )
                                ])),
                            SizedBox(
                              width: 2 * settings.userScalingBars.value,
                            ),
                            InkWell(
                                //behavior: HitTestBehavior.opaque, //makes tappable when no graphics
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
                                              .toString()))
                                      : SizedBox(
                                          width: 40 *
                                              settings.userScalingBars.value,
                                          height: 58.6666 *
                                              settings.userScalingBars.value,
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
