import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/commands.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Model/monster.dart';
import '../Resource/action_handler.dart';

Widget createLines(List<String> strings) {
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

  const dividerStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.white,
      fontSize: 8,
      letterSpacing: 2,
      height: 0.7,
      shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black)]);

  const smallStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.white,
      fontSize: 8,
      height: 0.8,
      shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black)]);
  const midStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.white,
      fontSize: 10,
      height: 0.8,
      shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black)]);
  const normalStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.white,
      fontSize: 14,
      height: 0.8,
      shadows: const [Shadow(offset: Offset(1, 1), color: Colors.black)]);
  List<Text> lines = [];
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
    if (isRightPartOfLastLine) {
      //TODO: handle differently: like use the same string instead of a separate one?
    } else {
      var text = Text.rich(
        TextSpan(
          children: textPartList,
        ),
      );
      lines.add(text);
    }

    //if starts with ^ -> medium size
    //if starts with * -> small size
    //if starts with *..... -> extra small font height margins
    //handle icons: %wound% etc.
    //handle special layout placements (graphics of aoes and infuse element typically):
    //really should add those layout specials to the card in json, but whatever.

  }
  return Align(
    //alignment: Alignment.center,
    child: Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: lines),
    ),
  );
}

class MonsterAbilityCardWidget extends StatefulWidget {
  //final String icon;
  final double height;
  final double borderWidth = 2;
  final MonsterModel data;

  const MonsterAbilityCardWidget(
      {Key? key,
      //required this.icon,
      this.height = 123,
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

  Widget _buildRear(){
    return Container(
        key: const ValueKey<int>(0),
        margin: const EdgeInsets.all(2),
    width: 180,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: widget.height,
          image: const AssetImage(
              "assets/images/psd/monsterAbility-back.png"),
        ),
      ],
    ));
  }

  Widget _buildFront(MonsterAbilityCardModel? card){

    String initText = card!.initiative.toString();
    if (initText.length == 1) {
      initText = "0" + initText;
    }
    return Container(
        key: const ValueKey<int>(1),
        margin: const EdgeInsets.all(2),
    width: 180,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: widget.height,
          image: const AssetImage(
              "assets/images/psd/monsterAbility-front.png"),
        ),
        Positioned(
          top: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                card.title,
                style: const TextStyle(
                    fontFamily: 'Pirata',
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                          offset: Offset(1, 1),
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
            left: 10.0,
            top: 24.0,
            child: Container(
              child: Text(
                initText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                          offset: Offset(1, 1),
                          color: Colors.black)
                    ]),
              ),
            )),
        Positioned(
            left: 4.0,
            top: 110.0,
            child: Container(
              child: Text(
                card.nr.toString(),
                style: const TextStyle(
                    fontFamily: 'Majalla',
                    color: Colors.white,
                    fontSize: 8,
                    shadows: [
                      Shadow(
                          offset: Offset(1, 1),
                          color: Colors.black)
                    ]),
              ),
            )),
        card.shuffle
            ? Positioned(
            right: 4.0,
            bottom: 4.0,
            child: Container(
              child: Image(
                height: widget.height * 0.14,
                image: const AssetImage(
                    "assets/images/abilities/shuffle.png"),
              ),
            ))
            : Container(),
        createLines(card.lines),
      ],
    ));
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation){
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotateAnim,
        child: widget,
        builder: (context, widget) {
          final value =  min(rotateAnim.value, pi/2);
          return Transform(
              transform: Matrix4.rotationX(value),
              child: widget,
          alignment: Alignment.center,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RoundState>(
        valueListenable: _gameState.roundState,
        builder: (context, value, child)
    {


      MonsterAbilityCardModel? card;
      if(_gameState.roundState.value == RoundState.playTurns) {
        card = _gameState
            .getDeck(widget.data.deck)!
            .discardPile
            .peek;
      }

      return GestureDetector(
          onTap: () {
            //open deck menu
            setState(() {
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: _transitionBuilder,layoutBuilder: (widget, list) => Stack(children: [widget!, ...list],),
            //switchInCurve: Curves.easeInBack,
            //switchOutCurve: Curves.easeInBack.flipped,
            child: _gameState.roundState.value == RoundState.playTurns
                ? _buildFront(card)
                : _buildRear()
          ),
              //AnimationController(duration: Duration(seconds: 1), vsync: 0);
              //CurvedAnimation(parent: null, curve: Curves.easeIn)
      //),

          );
    }
    );
  }
}
