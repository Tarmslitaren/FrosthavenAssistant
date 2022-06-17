import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frosthaven_assistant/Model/monster.dart';

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
  if (monster.type.levels[monster.level].boss != null) {
    //is boss
    if (elite) {
      return values;
    }
    data = monster.type.levels[monster.level].boss!;
  } else {
    if (elite) {
      data = monster.type.levels[monster.level].elite!;
    } else {
      data = monster.type.levels[monster.level].normal!;
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
  //log("input: "+input);
  //get the value:
  int lastIndex = input.length;
  for( int i = lastIndex; i < input.length; i++) {
    if(input[i]== " "){
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


String applyMonsterStats(String line, Monster monster) {
  //log("monster: " + monster.id);
  //log("line: "+line);
  List<String> tokens = [];
  List<String> eTokens = [];
  var normalTokens = getStatTokens(monster, false);
  var eliteTokens = getStatTokens(monster, true);

  MonsterStatsModel? normal = monster.type.levels[monster.level].boss ??
      monster.type.levels[monster.level].normal;
  MonsterStatsModel? elite = monster.type.levels[monster.level].elite;

  int partStartIndex = 1;
  bool isIconPart = false;
  String lastIconToken = "";
  int lastNonIconStartIndex = 0;
  for (int i = 0; i < line.length; i++) {
    if (line[i] == '%') {
      //TODO: do for all conditions + jump, pierce, add target  etc.

      if (isIconPart) {
        String iconToken = line.substring(partStartIndex, i);
        partStartIndex = i+1;
        lastIconToken = iconToken;
        isIconPart = false;
        lastNonIconStartIndex = i+1;
        continue; //skip one round
      } else {
        isIconPart = true;
      }
    }
    //log("line1.5: "+line.substring(0, i));
   // log("isIconPart: "+isIconPart.toString());
    //log("line[i]: "+line[i]);
    //when to do calculations: only after a token that can have a modifiable value
    if(lastIconToken.isNotEmpty && isIconPart == false && (line[i] == '%' || i == line.length-1 ||
        (line[i] == " "
            && line[i+1] == "%") //TODO: this is wrong. should ckeck regexp not a number? - other solution: make sure to end string at nr end and use ! to right align
    )){
      //parse this part
      int? normalResult;
      int? eliteResult;
      //we are assuming a token is followed eiter by a value or text. not both. TODO: examine if this is indeed correct (or change solution)
      //log("line2: "+line);
      String textPart = line.substring(lastNonIconStartIndex, i+1);
      //log("line3: "+line);
      //log("textpart: "+textPart);

      if (lastIconToken == "attack") {
        RegExp regEx = RegExp(r"(?=.*[a-z])");
        for (var item in normalTokens) {
          if (regEx.hasMatch(item.keys.first) == true) {
            tokens.add("%" + item.keys.first + "%"); //TODO: only add relevant tokens (i.e conditions that apply on attack)
          }
        }
        for (var item in eliteTokens) {
          if (regEx.hasMatch(item.keys.first) == true) {
            eTokens.add("%" + item.keys.first + "%");//TODO: only add relevant tokens (i.e conditions that apply on attack)
          }
        }

        //TODO: handle C and other calculations. use on any dynamic. also on attribute values (like shield C)
        int? number = parseIntValue(textPart);
        if (number != null) {
          normalResult = number + normal?.attack as int;
          if (elite != null) {
            eliteResult = number + elite.attack as int;
          }
        } else {
          //TODO: in case an attack with a value but no sign - should here add the tokens anyway? is there such a case?
        }
      }
      else if (lastIconToken == "range") {
        //later games the monsters have no range values
        if (normal?.range != 0) {
          int? number = parseIntValue(textPart);
          if (number != null) {
            normalResult = number + normal!.range;
            if (elite != null) {
              eliteResult = number + elite.range;
            }
          }
        }
      }
      else if (lastIconToken == "move") {
        int? number = parseIntValue(textPart);
        if (number != null) {
          if (normal?.move != null) {
            normalResult = number + normal!.move;
            if (elite != null) {
              eliteResult = number + elite.move;
            }
          }
        }
      }
      //TODO: handle shield, jump and add target. heal. maybe retaliate??
      else if (lastIconToken == "shield") {
      }
      else if (lastIconToken == "target") {
      }
      else if (lastIconToken == "retaliate") {
      }

      else if (lastIconToken == "jump") {
      }
      else if (lastIconToken == "heal") {
      }

      String newStringPart = "";
      if (normalResult != null) {
        newStringPart+=normalResult.toString();
        //add tokens
        for (var item in tokens) {
          newStringPart+= "|" + item; //disable text printout for conditions
        }
        if (elite != null) { //TODO: this si a shitty solution creating lots of problems. instead create anew string with ! to denote right hand side. and make sure to end it after the end of the nr.
          newStringPart += "/" + eliteResult.toString();
          for (var item in eTokens) {
            newStringPart+= "|" + item;
          }
        }
        //replace the substring
        line = line.replaceRange(lastNonIconStartIndex, i+1, newStringPart);
        i = lastNonIconStartIndex + newStringPart.length;

      }
    }

  }


  return line;

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

  List<Widget> lines = [];
  for (String line in strings) {
    bool isRightPartOfLastLine = false;
    var styleToUse = normalStyle;
    List<InlineSpan> textPartList = [];
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

    if (applyStats) {
      line = applyMonsterStats(line, monster);
    }


    int partStartIndex = 0;
    bool isIconPart = false;
    bool addText = true;
    for (int i = 0; i < line.length; i++) {
      if(line[i] == "|"){ //don't add text for conditions added with calculations
        addText = false;
      }
      if (line[i] == '%') {
        //TODO: handle monster attributes and calculations:
        //TODO: show / and elite values in yellow only if elites available and vice versa for normals
        //TODO: if + check if move/attack/range and change calculations
        //TODO: if attributes has line of %muddle% etc. add muddle icon etc to attack line
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
              textPartList.add(
                  TextSpan(text: iconTokenText, style: styleToUse));
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
      if(line[i] == "/"){
        //finish current part
        String textPart = line.substring(partStartIndex, i+1);
        textPartList.add(TextSpan(text: textPart, style: styleToUse));
        partStartIndex = i+1;
        styleToUse = eliteStyle; //TODO: check if different sizes needed
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
      Widget line = lines.last;
      lines.removeLast();
      lines.add(Row(
        children: [line, text],
      ));
    } else {
      lines.add(text);
    }
  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.max,
      children: lines);
}
