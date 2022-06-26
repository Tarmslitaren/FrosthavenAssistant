import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';

import '../Resource/game_state.dart';

double tempScale = 0.8;

double getIconHeight(String iconToken, double height) {
  if (iconToken == "air" ||
      iconToken == "earth" ||
      iconToken == "fire" ||
      iconToken == "ice" ||
      iconToken == "dark" ||
      iconToken == "light") {
    return height * 1.2;
  }
  if (iconToken.contains("aoe")) {
    return height * 2;
  }
  return height;
}

EdgeInsetsGeometry? getMarginForToken(String iconToken, double height,
    bool mainLine, CrossAxisAlignment alignment) {
  double margin = 0.5;
  if (alignment != CrossAxisAlignment.center) {
    margin = 0.1;
  }
  if (iconToken.contains("aoe")) {
    return EdgeInsets.only(left: margin * height, right: margin * height);
  }
  if (mainLine &&
      (iconToken == "attack" ||
          iconToken == "heal" ||
          iconToken == "loot" ||
          iconToken == "shield" ||
          iconToken == "move")) {
    return EdgeInsets.only(left: margin * height, right: margin * height);
  }
  if (iconToken == "air" ||
      iconToken == "earth" ||
      iconToken == "fire" ||
      iconToken == "ice" ||
      iconToken == "dark" ||
      iconToken == "light") {
    return EdgeInsets.only(
        top: 0.19 * height); //since icons lager, need lager margin top
  }
  return null;
}

List<Map<String, int>> getStatTokens(Monster monster, bool elite) {
  List<Map<String, int>> values = [];
  MonsterStatsModel data;
  if (monster.type.levels[monster.level.value].boss != null) {
    //is boss
    if (elite) {
      return values;
    }
    data = monster.type.levels[monster.level.value].boss!;
  } else {
    if (elite) {
      data = monster.type.levels[monster.level.value].elite!;
    } else {
      data = monster.type.levels[monster.level.value].normal!;
    }
  }
  for (String item in data.attributes) {
    if (item.substring(0, 1) == "%") {
      //parse item and then parse number;
      for (int i = 1; i < item.length; i++) {
        if (item[i] == '%') {
          String token = item.substring(1, i);
          int number = 0;
          if (i != item.length - 1) {
            String nr = item.substring(i + 1, item.length);
            number = int.parse(nr);
          }
          var map = <String, int>{};
          map[token] = number;
          values.add(map);
        }
      }
    }
  }
  return values;
}

int? parseIntValue(String input) {
  log("pares int input: " + input);
  //get the value:
  int lastIndex = input.length;
  for (int i = lastIndex; i < input.length; i++) {
    if (input[i] == " ") {
      lastIndex = i;
      break;
    }
  }
  String nr = input.substring(2, lastIndex);
  //log("nr: "+nr);
  String sign = input.substring(1, 2);
  bool minus = sign == "-";
  bool plus = sign == "+";
  int modifier = 1;
  if (minus) {
    modifier = -1;
  }
  if (!plus && !minus) {
    return null; //no op if straight number
  }
  if (int.tryParse(nr) != null) {
    int res = int.tryParse(nr)! * modifier;
    return res;
  }

  return null;
}

List<String> applyStatForToken(
    String formula,
    String line,
    int startIndex,
    int endIndex,
    Monster monster,
    bool showMinimal,
    String lastToken,
    List<Map<String, int>> normalTokens,
    List<Map<String, int>> eliteTokens) {
  List<String> retVal = [];
  List<String> tokens = [];
  List<String> eTokens = [];
  int normalValue = 0;
  int eliteValue = 0;
  MonsterStatsModel? normal = monster.type.levels[monster.level.value].boss ??
      monster.type.levels[monster.level.value].normal;
  MonsterStatsModel? elite = monster.type.levels[monster.level.value].elite;
  if (lastToken == "attack") {
    normalValue = normal!.attack;
    if (elite != null) {
      eliteValue = elite.attack;
    }

    RegExp regEx =
        RegExp(r"(?=.*[a-z])"); //not sure why I fdo this. only letters?
    for (var item in normalTokens) {
      if (regEx.hasMatch(item.keys.first) == true) {
        if (item.keys.first != "shield" &&
            item.keys.first != "retaliate" &&
            item.keys.first != "jump") {
          tokens.add("%${item.keys.first}%");
        }
      }
    }
    for (var item in eliteTokens) {
      if (regEx.hasMatch(item.keys.first) == true) {
        if (item.keys.first != "shield" &&
            item.keys.first != "retaliate" &&
            item.keys.first != "jump") {
          eTokens.add("%${item.keys.first}%");
        }
      }
    }
  } else if (lastToken == "range") {
    if (normal?.range != 0) {
      normalValue = normal!.range;
      if (elite != null) {
        eliteValue = elite.range;
      }
    }
  } else if (lastToken == "move") {
    normalValue = normal!.move;
    if (elite != null) {
      eliteValue = elite.move;
    }
    //TODO: add jump if has innate jump
  }

  //TODO: handle shield, jump and add target. heal. maybe retaliate??
  else if (lastToken == "shield") {
    //TOOD: at least this is needed
  } else if (lastToken == "target") {
  } else if (lastToken == "retaliate") {
  } else if (lastToken == "jump") {
  } else if (lastToken == "heal") {}
  int normalResult =
      StatCalculator.calculateFormula(formula + "+" + normalValue.toString());
  String newStartOfLine =
      line.substring(0, startIndex) + normalResult.toString();
  for (var item in eTokens) {
    newStartOfLine += "|" + item;
  }

  if (elite != null) {
    newStartOfLine += "/";
    retVal.add(newStartOfLine);

    int eliteResult =
        StatCalculator.calculateFormula(formula + "+" + eliteValue.toString());
    String eliteString = "!£" + eliteResult.toString();
    for (var item in eTokens) {
      eliteString += "|" + item;
    }
    retVal.add(eliteString);
  } else {
    retVal.add(newStartOfLine);
  }
  if (endIndex < line.length) {
    String leftOver = "!" + line.substring(endIndex + 1, line.length);

    //retVal.addAll(applyMonsterStats(leftOver, sizeToken, monster)); //TODO
    retVal.add(leftOver);
  }
  return retVal;
  return retVal;
}

List<String> applyMonsterStats(
    final String lineInput, String sizeToken, Monster monster) {
  String line = "" + lineInput; //make sure lineInput is not altered
  if (kDebugMode) {
    print("monster: ${monster.id}");
    print("line: $line");
  }

  List<String> retVal = [];

  //get the data
  var normalTokens = getStatTokens(monster, false);
  var eliteTokens = getStatTokens(monster, true);

  RegExp regExpNumbers = RegExp(r'^[\d ()xCL/*+-]+$');
  //first pass fix values only
  String lastToken =
      ""; //turn this into move or attack or whatever, then apply correct monster stat
  bool isInToken = false;
  int tokenStartIndex = 0;
  for (int i = 0; i < line.length; i++) {
    if (line[i] == "%") {
      if (!isInToken) {
        isInToken = true;
        tokenStartIndex = i + 1;
      } else {
        isInToken = false;
        lastToken = line.substring(tokenStartIndex, i);
      }
    }
    if ((line[i] == '+' ||
                line[i] == '-' ||
                line[i] == 'C' ||
                line[i] == 'L') &&
            (i == 0 ||
                line[i - 1] ==
                    ' ') //supposing there is always a leading whitespace to any formula
        ) {
      String formula = line[i];
      int startIndex = i;
      int endIndex = i;

      for (int j = i + 1; j < lineInput.length; j++) {
        String val = lineInput[j];
        if (val.contains(regExpNumbers)) {
          if (val != ' ') formula += val;
          endIndex = j;
        } else {
          i = j; //skip ahead
          if (lineInput[i - 1] == ' ') {
            i = j - 1; //restore any skipped whitespace
            endIndex = endIndex - 1;
          }
          break;
        }
      }
      if (formula.length > 1) {
        //this disallows a single digit or C,L. single C or L could be part of regular text
        //should do a pass where monster stats are calculated before applying formula

        if (lastToken.isNotEmpty) {
          retVal = applyStatForToken(
            formula,
            line,
            startIndex,
            endIndex,
            monster,
            false,
            lastToken,
            normalTokens,
            eliteTokens,
          );
          lastToken = "";
          if (retVal.isNotEmpty) {
            return retVal;
          }
        } else {
          int result = StatCalculator.calculateFormula(formula);
          line = line.replaceRange(startIndex, endIndex + 1, result.toString());
        }
      }
    }
  }

  return [line];
}

Widget createLines(List<String> strings, bool left, bool applyStats,
    Monster monster, CrossAxisAlignment alignment, double scale) {
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
      offset: Offset(1 * scale * tempScale, 1 * scale * tempScale),
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
      fontSize: 9 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  var midStyle = TextStyle(
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 12 * tempScale * scale,
      height: 0.9,
      shadows: [shadow]);
  var normalStyle = TextStyle(
      //maybe slightly bigger between chars space?
      fontFamily: 'Majalla',
      color: left ? Colors.black : Colors.white,
      fontSize: 14 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);

  var eliteStyle = TextStyle(
      //maybe slightly bigger between chars space?
      fontFamily: 'Majalla',
      color: Colors.yellow,
      fontSize: 14 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);

  var eliteSmallStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.yellow,
      fontSize: 9 * tempScale * scale,
      height: 0.8,
      shadows: [shadow]);
  var eliteMidStyle = TextStyle(
      fontFamily: 'Majalla',
      color: Colors.yellow,
      fontSize: 12 * tempScale * scale,
      height: 0.9,
      shadows: [shadow]);

  List<Text> lines = [];
  List<String> localStrings = [];
  localStrings.addAll(strings);
  List<InlineSpan> lastLineTextPartList = [];
  for (int i = 0; i < localStrings.length; i++) {
    String line = localStrings[i];
    String sizeToken = "";
    bool isRightPartOfLastLine = false;
    var styleToUse = normalStyle;
    List<InlineSpan> textPartList = [];
    if (line.startsWith('!')) {
      //add as
      isRightPartOfLastLine = true;
      line = line.substring(1, line.length);
    }
    if (line.startsWith('*')) {
      sizeToken = '*';
      styleToUse = smallStyle;
      line = line.substring(1, line.length);
      if (line.startsWith("....")) {
        styleToUse = dividerStyle;
      }
    }
    if (line.startsWith('^')) {
      sizeToken = '^';
      styleToUse = midStyle;
      line = line.substring(1, line.length);
    }
    if (applyStats) {
      List<String> statLines = applyMonsterStats(line, sizeToken, monster);
      line = statLines.removeAt(0);
      if (statLines.length > 0) {
        localStrings.insertAll(i + 1, statLines);
      }
    }

    int partStartIndex = 0;
    bool isIconPart = false;
    bool addText = true;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == "|") {
        //don't add text for conditions added with calculations
        addText = false;
      }
      if (line[i] == '%') {
        //TODO: handle monster attributes and calculations:
        //TODO: show / and elite values in yellow only if elites available and vice versa for normals
        //TODO: do for all conditions + jump, pierce, add target  etc.

        if (isIconPart) {
          //create token part
          String iconToken = line.substring(partStartIndex, i);
          String iconGfx = iconToken;
          if (left) {
            RegExp regEx = RegExp(
                r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
            if (regEx.hasMatch(_tokens[iconToken]!) == true) {
              iconGfx += "-medium-black";
            }
          }
          if (iconToken == "use") {
            //put use gfx on top of previous and add ':'
            WidgetSpan part = textPartList.removeLast() as WidgetSpan;
            Image lastImage = (part.child as Container).child as Image;
            textPartList.add(WidgetSpan(
                alignment: PlaceholderAlignment.top,
                style: TextStyle(fontSize: styleToUse.fontSize! * 0.8),
                child: Stack(
                  children: [
                    lastImage,
                    Image(
                      height: styleToUse.fontSize! * 1.2,
                      //alignment: Alignment.topCenter,
                      image: AssetImage("assets/images/abilities/$iconGfx.png"),
                    )
                  ],
                )));
            textPartList.add(TextSpan(text: ": ", style: styleToUse));
            //TODO: examine if removing the Container margins is the right thing to do for this case
          } else {
            double height = getIconHeight(iconToken, styleToUse.fontSize!);
            if (addText) {
              String? iconTokenText = _tokens[iconToken];
              textPartList
                  .add(TextSpan(text: iconTokenText, style: styleToUse));
            }
            bool mainLine = styleToUse == normalStyle;
            EdgeInsetsGeometry? margin =
                getMarginForToken(iconToken, height, mainLine, alignment);
            if (iconToken == "move" && monster.type.flying) {
              iconGfx = "flying";
            }
            Widget child = Image(
              height: height,
              //alignment: Alignment.topCenter,
              image: AssetImage("assets/images/abilities/$iconGfx.png"),
            );
            if (margin != null) {
              child = Container(
                margin: margin,
                child: child,
              );
            }
            textPartList.add(WidgetSpan(
                alignment: PlaceholderAlignment.top,
                style: TextStyle(fontSize: styleToUse.fontSize! * 0.8),
                //styleToUse, //don't ask (probably because height is 0.8
                child: child));
          }
          isIconPart = false;
          addText = true;
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
      if (line[i] == "£") {
        //finish current part
        String textPart = line.substring(partStartIndex, i + 1);
        //textPartList.add(TextSpan(text: textPart, style: styleToUse));
        partStartIndex = i + 1;
        if (styleToUse == normalStyle) {
          styleToUse = eliteStyle;
        } else if (styleToUse == smallStyle) {
          styleToUse = eliteSmallStyle;
        } else if (styleToUse == midStyle) {
          styleToUse = eliteMidStyle;
        }

        //TODO: check if different sizes needed
      }
    }

    if (partStartIndex < line.length) {
      String textPart = line.substring(partStartIndex, line.length);
      textPartList.add(TextSpan(text: textPart, style: styleToUse));
    }
    TextAlign textAlign = TextAlign.center;
    if (alignment == CrossAxisAlignment.start) {
      textAlign = TextAlign.start;
    }
    if (alignment == CrossAxisAlignment.end) {
      textAlign = TextAlign.end;
    }
    var text = Text.rich(
      textAlign: textAlign,
      TextSpan(
        children: textPartList,
      ),
    );
    if (isRightPartOfLastLine) {
      lines.removeLast();
      textPartList.insertAll(0, lastLineTextPartList);
      text = Text.rich(
        textAlign: textAlign,
        TextSpan(
          children: textPartList,
        ),
      );
      lines.add(text);
    } else {
      lines.add(text);
    }
    lastLineTextPartList = textPartList;
  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.max,
      children: lines);
}
