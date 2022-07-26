
import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/action_handler.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';



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

    //to load save state
    _gameState.modelData.addListener(() {
        setState(() {});
    });
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333),
        child: child);
  }


  Widget buildSlideAnimation(Widget child, Key key) {
    if(!animationsEnabled) {
      return Container(
        margin: const EdgeInsets.only(left: 33.3333),
          child: child);
    }
    return Container(
        key: key,
        child: TranslationAnimatedWidget(
          //curve: Curves.slowMiddle,
          animationFinished: (bool finished){
            if (finished) {
              animationsEnabled = false;
            }
          },
            duration: Duration(milliseconds: cardAnimationDuration),
            enabled: true,
            curve: Curves.easeIn,
            values: const [
              Offset(0, 0), //left to drawpile
              Offset(0, 0), //left to drawpile
              Offset(33.3333, 0), //end
            ],
                child: RotationAnimatedWidget(
                    enabled: true,
                    values: [
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: -15),
                      Rotation.deg(x: 0, y: 0, z: 0),
                    ],
                    duration: Duration(milliseconds:cardAnimationDuration),
                    child: child))

    );

  }

  static int cardAnimationDuration = 1200;
  bool animationsEnabled = false;
  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 58.6666;
    double height = 40;

    var screenSize = MediaQuery.of(context).size;
    double xOffset = -(screenSize.width/2 - 66.6666);
    double yOffset = -(screenSize.height/2 - height/2);

    return Container(
      key: key, //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: animationsEnabled? TranslationAnimatedWidget(
        duration: Duration(milliseconds: cardAnimationDuration),
        enabled: true,
        values: [
          Offset(-(width+2), 0), //left to drawpile
          Offset(xOffset, yOffset), //center of screen
          Offset(xOffset, yOffset), //center of screen
          Offset(xOffset, yOffset), //center of screen
          const Offset(0, 0), //end
        ],
        child: ScaleAnimatedWidget( //does nothing
          enabled: true,
            duration: Duration(milliseconds: cardAnimationDuration),

            values: const [
              1,
              4,
              4,
              4,
              1
            ],
            child: RotationAnimatedWidget(
              enabled: true,
               values: [
                 //Rotation.deg(x: 0, y: 0, z: 0),
                 //Rotation.deg(x:0, y: 0, z: 90),
                 Rotation.deg(x: 0, y: 0, z: 180),
                 //Rotation.deg(x: 0, y: 0, z: 270),
                 Rotation.deg(x: 0, y: 0, z: 360),
               ],
               duration: Duration(milliseconds:(cardAnimationDuration * 0.25).ceil()),
                child: child)))
            :child
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAnimating = false; //is not doing anything now. in case flip animation is added
    return  Container( //Positioned( //only a positioned if place in a stack
        //right: 0,
       // bottom: 0,
        child: Container(
          width: 153, //TODO: make smaller if can't fit on screen?
          height: 40,
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
                                  width: 58.6666,
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
                                  fontSize: 12,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          offset: Offset(1, 1),
                                          color: Colors.black)
                                    ]),
                              ))
                        ])),
                    const SizedBox(
                      width: 2,
                    ),
                    GestureDetector(
                        onTap: () {
                          openDialog(context, const ModifierCardMenu());
                        },
                        child: Container(
                            //width: 105 * smallify, //155
                            child: Stack(children: [
                              _gameState.modifierDeck.discardPile.size() > 2
                                  ? buildStayAnimation(Container(
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
                                      ))), )
                                  : Container(),
                              _gameState.modifierDeck.discardPile.size() > 1
                                  ? buildSlideAnimation(RotationTransition(
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
                                      )), Key(_gameState.modifierDeck.discardPile.size().toString()))
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
                                      width: 66.6666,
                                      height: 40,
                                    ),
                            ])))
                  ],
                );
              }),
        ));
  }
}
