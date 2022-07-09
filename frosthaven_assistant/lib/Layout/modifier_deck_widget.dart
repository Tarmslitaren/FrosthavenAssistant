import 'dart:math';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/enums.dart';

double tempScale = 0.8;

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

  @override
  Widget build(BuildContext context) {
    int remainingCards = _gameState.modifierDeck.drawPile.size();
    return Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: 230,
          height: 60,
          child: ValueListenableBuilder<int>(
              valueListenable: _gameState.modifierDeck.cardCount,
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
                                  revealed: false)
                              : Container(
                                  width: 88,
                                  height: 60,
                                  color:
                                      Color(int.parse("7A000000", radix: 16))),
                          Positioned(
                              bottom: 1,
                              right: 2,
                              child: Text(
                                _gameState.modifierDeck.cardCount.value
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          offset: Offset(1, 1),
                                          color: Colors.black)
                                    ]),
                              ))
                        ])),
                    SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                        onTap: () {
                          //TODO: open the card menu
                        },
                        child: Container(
                            width: 155,
                            //TODO: WHYYY!? if I make the width big enough, the rotated widget can be seen overflowing the height?!
                            child: Stack(children: [
                              _gameState.modifierDeck.discardPile.size() > 1
                                  ? Positioned(
                                      left: 55,
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
                                          )))
                                  : Container(),
                              _gameState.modifierDeck.discardPile
                                      .isNotEmpty //TODO: not exactly right: need to save last cards drawn even if they needed to be shuffled
                                  ? ModifierCardWidget(
                                      card: _gameState
                                          .modifierDeck.discardPile.peek,
                                      revealed: true,
                                    )
                                  : Container(
                                      width: 100,
                                      //todo proper size same as card. so it can be interacted with
                                      height: 60,
                                    ),
                            ])))
                  ],
                );
              }),
        ));
  }
}
