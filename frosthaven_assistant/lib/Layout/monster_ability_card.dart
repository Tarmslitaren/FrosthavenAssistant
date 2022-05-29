import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/monster.dart';
import '../Resource/action_handler.dart';

double tempScale = 0.8;

Widget createLines(List<String> strings, bool left, CrossAxisAlignment alignment, double scale) {
  const Map<String, String> _tokens = {
    "attack": "Attack",
    "move": "Move",
    "range": "Range",
    "heal": "Heal",
    "target": "Target",
    "shield": "Shield",
    "loot": "Loot",
    "retaliate": "Retaliate",
    "jump": "Jump",
    "stun": "STUN",
    "wound": "WOUND",
    "disarm": "DISARM",
    "immobilize": "IMMOBILIZE",
    "poison": "POISON",
    "invisible": "INVISIBLE",
    "strengthen": "STRENGTHEN",
    "muddle": "MUDDLE",
    "regenerate": "REGENERATE",
    "ward": "WARD",
    "impair": "IMPAIR",
    "bane": "BANE",
    "brittle": "BRITTLE",
    "chill": "CHILL",
    "infect": "INFECT",
    "rupture": "RUPTURE",
    "push": "PUSH",
    "pull": "PULL",
    "pierce": "PIERCE",
    "curse": "CURSE",
    "bless": "BLESS",
    "and": "and"
  };

  var shadow = Shadow(
      offset: Offset(1 * scale, 1 * scale),
      color: left ? Colors.white : Colors.black);

  var dividerStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 8 * tempScale * scale,
      letterSpacing: 2 * tempScale * scale,
      height: 0.7,
      shadows: [shadow]);

  var smallStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 8 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  var midStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 10 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  var normalStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 14 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  List<Widget> lines = [];
  for (String line in strings) {
    bool isRightPartOfLastLine = false;
    var styleToUse = normalStyle;
    List<InlineSpan> textPartList = [];
    //TODO: handle !: ! means align right (used when textsize changes on same line)
    if (line.startsWith('!')) {
      //add as
      isRightPartOfLastLine = true;
      line = line.substring(1, line.length);
    }
    if (line.startsWith('*')) {
      styleToUse = smallStyle;
      line = line.substring(1, line.length);
      if (line.startsWith("....")) {
        styleToUse = dividerStyle;
      }
    }
    if (line.startsWith('^')) {
      styleToUse = midStyle;
      line = line.substring(1, line.length);
    }

    int partStartIndex = 0;
    bool isIconPart = false;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '%') {
        //TODO: handle monster attributes and calculations:
        //TODO: show / and elite values in yellow only if elites available and vice versa for normals
        //TODO: if + check if move/attack/range and change calculations
        //TODO: if attributes has line of %muddle% etc. add muddle icon etc to attack line
        //TODO: do for all conditions + jump, pierce, add target  etc.

        //TODO: handle element use: use image on top (stack?) or make new images.
        if (isIconPart) {
          //create token part
          String iconToken = line.substring(partStartIndex, i);
          String? iconTokenText = _tokens[iconToken];
          textPartList.add(TextSpan(text: iconTokenText, style: styleToUse));
          textPartList.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image(
                height: styleToUse.fontSize,
                //TODO: not correct for infusions or area of effects
                alignment: Alignment.topCenter,
                image: AssetImage("assets/images/abilities/$iconToken.png"),
              )));
          isIconPart = false;
        } else {
          //create part up to now if length more than 0
          if (i > 0 && partStartIndex < i) {
            String textPart = line.substring(partStartIndex, i - 1);
            textPartList.add(TextSpan(text: textPart, style: styleToUse));
          }
          isIconPart = true;
        }
        partStartIndex = i + 1;
      }
    }

    if (partStartIndex < line.length) {
      String textPart = line.substring(partStartIndex, line.length);
      textPartList.add(TextSpan(text: textPart, style: styleToUse));
    }
    var text = Text.rich(
      TextSpan(
        children: textPartList,
      ),
    );
    if (isRightPartOfLastLine) {
      Widget line = lines.last;
      lines.removeLast();
      lines.add(Row(
        children: [line, text],
      ));
    } else {
      lines.add(text);
    }

    //if starts with ^ -> medium size
    //if starts with * -> small size
    //if starts with *..... -> extra small font height margins
    //handle icons: %wound% etc.
    //handle special layout placements (graphics of aoes and infuse element typically):
    //really should add those layout specials to the card in json, but whatever.

  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.max,
      children: lines);
}

class MonsterAbilityCardWidget extends StatefulWidget {
  //final double height;
  //final double borderWidth = 2;
  final MonsterModel data;

  const MonsterAbilityCardWidget(
      {Key? key,
      //this.height = 123,
      required this.data})
      : super(key: key);

  @override
  _MonsterAbilityCardWidgetState createState() =>
      _MonsterAbilityCardWidgetState();
}

class _MonsterAbilityCardWidgetState extends State<MonsterAbilityCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  final GameState _gameState = getIt<GameState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildRear(double scale) {
    int size = 8;
    for (var deck in _gameState.currentAbilityDecks) {
      if (deck.name == widget.data.deck) {
        size = deck.drawPile.size();
        break;
      }
    }

    return Container(
        key: const ValueKey<int>(0),
        margin: EdgeInsets.all(2 * scale),
        //width: 180*tempScale*scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0 * scale),
              child: Image(
                height: 123 * tempScale * scale,
                image: const AssetImage(
                    "assets/images/psd/monsterAbility-back.png"),
              ),
            ),
            Positioned(
                right: 6.0 * tempScale * scale,
                bottom: 0 * tempScale * scale,
                child: Container(
                  child: Text(
                    size.toString(),
                    style: TextStyle(
                        fontFamily: 'Majalla',
                        color: Colors.white,
                        fontSize: 16 * tempScale * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: Colors.black)
                        ]),
                  ),
                )),
          ],
        ));
  }

  Widget _buildFront(MonsterAbilityCardModel? card, double scale) {
    String initText = card!.initiative.toString();
    if (initText.length == 1) {
      initText = "0" + initText;
    }
    return Container(
        key: const ValueKey<int>(1),
        margin: EdgeInsets.all(2 * scale),
        width: 180 * tempScale * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0 * scale),
              child: Image(
                height: 123 * tempScale * scale,
                image: const AssetImage(
                    "assets/images/psd/monsterAbility-front.png"),
              ),
            ),
            Positioned(
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    card.title,
                    style: TextStyle(
                        fontFamily: 'Pirata',
                        color: Colors.white,
                        fontSize: 14 * tempScale * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: Colors.black)
                        ]),
                  ),
                ],
              ),
            ),

            //right: 100,
            //alignment: Alignment.topCenter,
            //child:

            Positioned(
                left: 7.0 * tempScale * scale,
                top: 16.0 * tempScale * scale,
                child: Container(
                  child: Text(
                    textAlign: TextAlign.center,
                    initText,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20 * tempScale * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: Colors.black)
                        ]),
                  ),
                )),
            Positioned(
                left: 6.0 * tempScale * scale,
                bottom: 0.5 * tempScale * scale,
                child: Container(
                  child: Text(
                    card.nr.toString(),
                    style: TextStyle(
                        fontFamily: 'Majalla',
                        color: Colors.white,
                        fontSize: 8 * tempScale * scale,
                        shadows: [
                          Shadow(
                              offset: Offset(1 * scale, 1 * scale),
                              color: Colors.black)
                        ]),
                  ),
                )),
            card.shuffle
                ? Positioned(
                    right: 4.0 * tempScale * scale,
                    bottom: 4.0 * tempScale * scale,
                    child: Container(
                      child: Image(
                        height: 123 * tempScale * 0.14 * scale,
                        image: const AssetImage(
                            "assets/images/abilities/shuffle.png"),
                      ),
                    ))
                : Container(),
            Positioned(
              top: 24.0 * tempScale * scale,
              //alignment: Alignment.center,
              child: SizedBox(
                height: 80 * scale * tempScale,
                //alignment: Alignment.center,
                // margin: EdgeInsets.only(top: 24*tempScale*scale),

                child: createLines(card.lines, false, CrossAxisAlignment.center, scale),
              ),
            )
          ],
        ));
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value = min(rotateAnim.value, pi / 2);
          return Transform(
            transform: Matrix4.rotationX(value),
            child: widget,
            alignment: Alignment.center,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    return ValueListenableBuilder<RoundState>(
        valueListenable: _gameState.roundState,
        builder: (context, value, child) {
          MonsterAbilityCardModel? card;
          if (_gameState.roundState.value == RoundState.playTurns) {
            card = _gameState.getDeck(widget.data.deck)!.discardPile.peek;
          }

          return GestureDetector(
            onTap: () {
              //open deck menu
              setState(() {});
            },
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: _transitionBuilder,
                layoutBuilder: (widget, list) => Stack(
                      children: [widget!, ...list],
                    ),
                //switchInCurve: Curves.easeInBack,
                //switchOutCurve: Curves.easeInBack.flipped,
                child: _gameState.roundState.value == RoundState.playTurns
                    ? _buildFront(card, scale)
                    : _buildRear(scale)),
            //AnimationController(duration: Duration(seconds: 1), vsync: 0);
            //CurvedAnimation(parent: null, curve: Curves.easeIn)
            //),
          );
        });
  }
}
