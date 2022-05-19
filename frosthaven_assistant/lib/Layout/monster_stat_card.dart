import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';

import '../Model/monster.dart';

//TODO: extract this to separate module
Widget createLines(List<String> strings, final bool left) {
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

  var shadow = Shadow(offset: Offset(1, 1), color: left ? Colors.white : Colors.black);

  var smallStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 8,
      height: 0.8,
      shadows: [shadow]);
  var midStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 10,
      height: 0.8,
      shadows: [shadow]);
  var normalStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 12,
      height: 0.8,
      shadows: [shadow]);
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
        //TODO: do for all conditions + jump, retaliate etc.
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

class MonsterStatCardWidget extends StatefulWidget {
  //final String icon;
  final double height;
  final double borderWidth = 2;
  final int level;
  final MonsterModel data;

  final leftStyle =
      const TextStyle(fontFamily: 'Majalla', color: Colors.black, fontSize: 16,height: 1.2,
          shadows: [Shadow(offset: Offset(1, 1), color: Colors.black12)]);


  final rightStyle = const TextStyle(
      fontFamily: 'Majalla',
      color: Colors.white,
      fontSize: 16,
      height: 1.2,
      shadows: [Shadow(offset: Offset(1, 1), color: Colors.black)]);

  const MonsterStatCardWidget({
    Key? key,
    //required this.icon,
    this.height = 123,
    required this.data,
    required this.level,
  }) : super(key: key);

  @override
  _MonsterStatCardWidgetState createState() => _MonsterStatCardWidgetState();
}

class _MonsterStatCardWidgetState extends State<MonsterStatCardWidget> {
// Define the various properties with default values. Update these properties
// when the user taps a FloatingActionButton.
//late MonsterData _data;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _level = widget.level;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //if grayscale mode: fade in the stats
          setState(() {});
        },
        child: Container(
            margin: const EdgeInsets.all(2),
            child: Stack(
              //alignment: Alignment.center,
              children: [
                Image(
                  height: widget.height,
                  image: const AssetImage(
                      "assets/images/psd/monsterStats-normal.png"),
                ),
                Positioned(
                  left: 72.0,
                  top: 4.0,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.data.levels[_level].normal!.health.toString(),
                          style: widget.leftStyle),
                      Text(widget.data.levels[_level].normal!.attack.toString(),
                          style: widget.leftStyle),
                      Text(widget.data.levels[_level].normal!.move.toString(),
                          style: widget.leftStyle),
                      Text(
                          widget.data.levels[_level].normal?.range != 0
                              ? widget.data.levels[_level].normal!.range
                                  .toString()
                              : "-",
                          style: widget.leftStyle),
                    ],
                  ),
                ),
                Positioned(
                  width: 65,
                  left: 6.0,
                  top: -20.0,
                  child: createLines(
                      widget.data.levels[_level].normal!.attributes, true),
                ),
                Positioned(
                  right: 72.0,
                  top: 4.0,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.data.levels[_level].normal!.health.toString(),
                          style: widget.rightStyle),
                      Text(widget.data.levels[_level].normal!.attack.toString(),
                          style: widget.rightStyle),
                      Text(widget.data.levels[_level].normal!.move.toString(),
                          style: widget.rightStyle),
                      Text(
                          widget.data.levels[_level].normal?.range != 0
                              ? widget.data.levels[_level].normal!.range
                              .toString()
                              : "-",
                          style: widget.rightStyle),
                    ],
                  ),
                ),
                Positioned(
                  width: 65,
                  right: 0.0,
                  top: -20.0,
                  child: createLines(
                      widget.data.levels[_level].normal!.attributes, false),
                )
              ],
            )));
  }
}
