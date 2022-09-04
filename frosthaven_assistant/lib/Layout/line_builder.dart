
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';

import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';
import 'package:dotted_border/dotted_border.dart';

class LineBuilder {

  static const Map<String, String> _tokens = {
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

  static double _getIconHeight(String iconToken, double height) {
    if (iconToken == "air" ||
        iconToken == "earth" ||
        iconToken == "fire" ||
        iconToken == "ice" ||
        iconToken == "dark" ||
        iconToken == "light"||
        iconToken == "any"
    ) {
      return height * 1.2;
    }
    if (iconToken.contains("aoe")) {
      return height * 2;
    }
    return height;
  }

  static EdgeInsetsGeometry _getMarginForToken(String iconToken, double height,
      bool mainLine, CrossAxisAlignment alignment, bool isFrostHavenStyle) {
    double margin = 0.2;

    if (alignment != CrossAxisAlignment.center) {
      margin = 0.1;
    }
    if(isFrostHavenStyle)  {
      margin = 0;
    }
    if (iconToken.contains("aoe")) {
      return EdgeInsets.only(left: margin * height, right: margin * height);
    }
    if (
    mainLine
        &&
        (iconToken == "attack" ||
            iconToken == "heal" ||
            iconToken == "loot" ||
            iconToken == "shield" ||
            iconToken == "move")) {
      return EdgeInsets.only(left: margin * height, right: margin * height);
    }
    if (
    mainLine
        &&
        (iconToken == "pierce" ||
            iconToken == "target" ||
            iconToken == "curse" ||
            iconToken == "bless" ||
            iconToken == "curse" ||
            iconToken == "push" ||
            iconToken == "pull" ||
            iconToken == "poison" ||
            iconToken == "wound" ||
            iconToken == "infect" ||
            iconToken == "chill" ||
            iconToken == "disarm" ||
            iconToken == "immobilize" ||
            iconToken == "stun" ||
            iconToken == "muddle"
        )) {
      //smaller magins for secondary modifiers
      return const EdgeInsets.all(0);
    }
    if (iconToken == "air" ||
        iconToken == "earth" ||
        iconToken == "fire" ||
        iconToken == "ice" ||
        iconToken == "dark" ||
        iconToken == "light"||
        iconToken == "light"||
    iconToken == "any"
    ) {
      //this caused elements to not align well especially noticeable in case of use element to create element
      //return EdgeInsets.only(top: 0.19 * height); //since icons lager, need lager margin top
    }
    return EdgeInsets.only(left: 0.1 * height, right: 0.1 * height);
  }

  static Map<String, int> _getStatTokens(Monster monster, bool elite) {
    var map = <String, int>{};
    MonsterStatsModel data;
    if (monster.type.levels[monster.level.value].boss != null) {
      //is boss
      if (elite) {
        return map;
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

      //remove size modifiers (only used for immobilize since it's so long it overflows.)
      String sizeMod = (item.substring(0, 1));
      if(sizeMod == "^" || sizeMod == "*") {
        item = item.substring(1);
      }
      if (item.substring(0, 1) == "%") { //expects token to be first in line. is this ok?
        //parse item and then parse number;
        for (int i = 1; i < item.length; i++) {
          if (item[i] == '%') {
            String token = item.substring(1, i);
            int number = 0;
            if (i != item.length - 1)
            {
              for (int j = i+2; j < item.length; j++){
                if(item[j] == ' ' || j == item.length-1){
                  //need to find end of nr and ignore the rest
                  String nr = item.substring(i + 1, j+1);
                  int? res = StatCalculator.calculateFormula(nr);
                  if(res != null){
                    number = res;
                  }else {
                    if(kDebugMode) {
                      print("failed calculation for formula: " + nr +  "for token: "+ token);

                    }
                  }
                  break;
                }
              }

            }

            if (token == "target" && number == 0) {
              //target needs a nr
              continue;
            }
            map[token] = number;
            break; //only one token added per line
          }
        }
      }
    }
    return map;
  }

  static List<String> _applyStatForToken(
      String formula,
      String line,
      String sizeModifier,
      int startIndex,
      int endIndex,
      Monster monster,
      bool showNormal,
      bool showElite,
      String lastToken,
      Map<String, int> normalTokens,
      Map<String, int> eliteTokens) {

    if(!showElite && !showNormal){
      return [line]; //?
    }

    List<String> retVal = [];
    List<String> tokens = [];
    List<String> eTokens = [];
    int normalValue = 0;
    int eliteValue = 0;
    bool skipCalculation = false; //in case uncalculable
    MonsterStatsModel? normal = monster.type.levels[monster.level.value].boss ??
        monster.type.levels[monster.level.value].normal;
    MonsterStatsModel? elite = monster.type.levels[monster.level.value].elite;
    if (lastToken == "attack") {
      int? calc = StatCalculator.calculateFormula(normal!.attack);
      if(calc != null) {
        normalValue = calc;
      } else {
        skipCalculation = true;
      }
      if (elite != null) {
        calc = StatCalculator.calculateFormula(elite.attack);
        if(calc != null) {
          eliteValue = calc;
        }
      }

      RegExp regEx =
          RegExp(r"(?=.*[a-z])"); //not sure why I fdo this. only letters?
      for (var item in normalTokens.keys) {
        if (regEx.hasMatch(item) == true) {
          if (item != "shield" &&
              item != "retaliate" &&
              item != "range" &&
              item != "jump") {
            tokens.add("%$item%");
          }
        }
      }
      for (var item in eliteTokens.keys) {
        if (regEx.hasMatch(item) == true) {
          if (item != "shield" &&
              item != "retaliate" &&
              item != "range" &&
              item != "jump") {
            eTokens.add("%$item%");
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
      normalValue = StatCalculator.calculateFormula(normal!.move)!;
      if (elite != null) {
        eliteValue = eliteValue = StatCalculator.calculateFormula(elite.move)!;
      }
      //TODO: add jump if has innate jump
    }

    else if (lastToken == "shield") {
      int? value = normalTokens["shield"];
      int? eValue = eliteTokens["shield"];
      if (elite != null && eValue != null) {
        eliteValue = eValue;
      }
      if (normal != null && value != null) {
        normalValue = value;
      }
    } else if (lastToken == "retaliate") {
      int? value = normalTokens["retaliate"];
      int? eValue = eliteTokens["retaliate"];
      if (elite != null && eValue != null) {
        eliteValue = eValue;
      }
      if (normal != null && value != null) {
        normalValue = value;
      }
    } else if (lastToken == "target") {
      //only if there is ever a +x target
      /*int? value = normalTokens["target"];
      int? eValue = eliteTokens["target"];
      if (elite != null && eValue != null) {
        eliteValue = eValue;
      }
      if (normal != null && value != null) {
        normalValue = value;
      }*/
    }
    String normalResult = formula;
    if (!skipCalculation) {
      int? res = StatCalculator.calculateFormula(formula + "+" + normalValue.toString());

      if (res != null && res < 0) {
        res = 0; //needed for blood tumor: has 0 move and a -1 move card
      }
      if (res == null) {
        skipCalculation = true;
      } else {
        normalResult = res.toString();
      }
    }


    String newStartOfLine = line.substring(0, startIndex);
    if(showNormal) {
      newStartOfLine += normalResult;
      if (!skipCalculation) {
        for (var item in tokens) {
          newStartOfLine += "|" + item;
          //add nr if applicable
          String key = item.substring(1, item.length - 1);
          int value = normalTokens[key]!;
          if (value > 0) {
            newStartOfLine += " " + value.toString();
          }
        }
      }
    }

    if (elite != null && !skipCalculation && showElite) {
      if(showNormal) {
        newStartOfLine += "/";
      }
      retVal.add(newStartOfLine);

      int eliteResult = StatCalculator.calculateFormula(
          formula + "+" + eliteValue.toString())!;
      if (eliteResult < 0) {
        eliteResult = 0;
      }
      String eliteString = "!" + sizeModifier + "£" + eliteResult.toString();
      for (var item in eTokens) {
        eliteString += "|" + item;

        //add nr if applicable
        String key = item.substring(1, item.length-1);
        int value = eliteTokens[key]!;
        if(value > 0){
          eliteString += " " + value.toString();
        }
      }
      retVal.add(eliteString);
    } else {
      retVal.add(newStartOfLine);
    }
    if (endIndex < line.length) {
      String leftOver =
          "!" + sizeModifier + line.substring(endIndex + 1, line.length);

      //retVal.addAll(applyMonsterStats(leftOver, sizeToken, monster));
      retVal.add(leftOver);
    }
    return retVal;
  }

  static List<String> _applyMonsterStats(
      final String lineInput, String sizeToken, Monster monster, bool forceShowAll) {

    bool showElite = monster.monsterInstances.value.isNotEmpty && monster.monsterInstances.value[0].type == MonsterType.elite || monster.isActive;
    bool showNormal = monster.monsterInstances.value.isNotEmpty && monster.monsterInstances.value.last.type != MonsterType.elite || monster.isActive;
    if(forceShowAll) {
      showElite = true;
      showNormal = true;
    }
    String line = "" + lineInput; //make sure lineInput is not altered
    if (kDebugMode) {
      //print("monster: ${monster.id}");
      //print("line: $line");
    }

    List<String> retVal = [];

    //get the data
    var normalTokens = _getStatTokens(monster, false);
    var eliteTokens = _getStatTokens(monster, true);

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
      if (!isInToken &&
                  (line[i] == '+' ||
                      line[i] == '-' ||
                      line[i] == 'C' ||
                      line[i] == 'L') ||
              (line[i].contains(regExpNumbers) &&
                      lastToken
                          .isEmpty) //plain numbers cant be calculated for tokens (e.g. attack 1 is not same as attack +1)
                  &&
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
            //hack for when a formula is followed by " (..."
            if (i > 0 && lineInput[i - 1] == '(') {
              i = j - 1; //restore any skipped (
              endIndex = endIndex - 1;
              formula = formula.substring(0, formula.length - 1);
              if (i > 1 && lineInput[i - 2] == ' ') {
                i = j - 1; //restore any skipped whitespace
                endIndex = endIndex - 1;
              }
            }
            break;
          }
        }
        if (formula.length > 1 && lastToken.isNotEmpty || formula.length > 2) {
          //this disallows a single digit or C,L. single C or L could be part of regular text
          //for a formula to work (oustside of plain C or L) it must either be modifying a token vslue or be 3+ chars long
          //might not be right. test.
          if (kDebugMode) {
            //print("formula:$formula");
          }

          if (lastToken.isNotEmpty) {
            retVal = _applyStatForToken(
              formula,
              line,
              sizeToken,
              startIndex,
              endIndex,
              monster,
              showNormal,
              showElite,
              lastToken,
              normalTokens,
              eliteTokens,
            );
            lastToken = "";
            if (retVal.isNotEmpty) {
              return retVal;
            }
          } else {
            int? result = StatCalculator.calculateFormula(formula);
            if(result != null) {
              if (result < 0) {
                //just some nicety. probably never applies
                result = 0;
              }
              line =
                  line.replaceRange(
                      startIndex, endIndex + 1, result.toString());
            }
          }
        }
      }
    }

    return [line];
  }

  static Widget createLinesColumn(CrossAxisAlignment alignment, List<Widget> lines) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.max,
        children: lines);
  }

  static List<String> convertLinesToFH(List<String> lines) {
    //move lines up when they should
    //add container markers here as well
    List<String> retVal = [];
    bool isSubLine = false;
    bool isReallySubLine = false;
    bool isConditional = false;
    for(int i = 0; i < lines.length; i++) {
      String line = lines[i];
      //if(line.contains("%use")/*|| line.toLowerCase().contains("if")*/){
     //   isConditional = true;
      //  retVal.add("[conditionalStart]");
      //}
      if(line == "[r]" && (lines[i+1].contains('%use') || lines[i+1].toLowerCase().contains('if') ||
          (lines.length > i+2 && lines[i+2].toLowerCase().contains('if'))
      )) {
        isConditional = true;
       // retVal.add("[conditionalStart]");
      }
      if(line == "[/r]" && isConditional) {
        isConditional = false;
       // retVal.add("[conditionalEnd]");
      }

      if(line == "*Self") {
        line = "!^ self";
      }

      line = line.replaceAll("Affect", "Target");
      //the affect keyword is presumably because in base goomhaven you can only target enemies.
      // this is changed already in JotL.

      if(line.startsWith("*")) { //now for both * and *..... potential problems?
        //reset
        if(isReallySubLine){ //&& !isConditional
          retVal.add("[subLineEnd]");

        }
        isReallySubLine = false;
        isSubLine = false;
        isConditional = false;

      }

      //removing conditional here is a bit of a cop out. if fixes one bug, but also -no handling of conditionals...
      if(line.startsWith("^") && isSubLine && !isConditional){
        //check if match right align issues
        if(!isConditional && !isReallySubLine) {
          retVal.add("[subLineStart]");
          isReallySubLine = true;
        }
        if(line[1] == '%' ||
            //these are all very... assuming.
            line.startsWith("^Self") ||
            line.startsWith("^Advantage") ||
            //only target on same line for non valued tokens
            (line.startsWith("^Target") && lines[i-1].contains('%push%')) ||
            (line.startsWith("^Target") && lines[i-1].contains('%pull%')) ||
            (line.startsWith("^Target") && lines[i-1].startsWith('%') && lines[i-1].endsWith('%')) || //this is to add sub line after a lone condition
            (line.startsWith("^Target") && lines[i-1].startsWith('^%') && lines[i-1].endsWith('%')) || //you will not want a linebreak after a lone poison sub line
            line.startsWith("^All") && !line.startsWith("^All attacks")&& !line.startsWith("^All targets")) {
          line = "!$line";
          line = line.replaceFirst("Self", "self");
          line = line.replaceFirst("All", "all");
          if(retVal.last == "[subLineStart]"){
            retVal.last = "![subLineStart]";
          }
        }

        if(retVal.last.endsWith("%") && line.endsWith("adjacent enemy")){ //blood ooze 62 hack
          retVal[retVal.length-2] ="[subLineStart]";
        }
      }
      if(line.startsWith("^") && isReallySubLine) {
        //I know.
        //we add a linebreaker at same time as we attach line to last,
        // because we only look at lastLineTextPartList later
        if(retVal.last != "[subLineStart]") {
          retVal.add("!^[lineBreak]");
        }
        line = "!$line";
      }
      else if(line.startsWith("!") || line.startsWith("*") || line.startsWith("^")){
        //ignore
      }else{ //if(line != "[c]" && line != "[r]"){
        if(!isSubLine) {
          isSubLine = true;
        }else {
          if(isReallySubLine){ //&&!isConditional
            retVal.add("[subLineEnd]");
            isReallySubLine = false;
            isSubLine = false;
          }

        }
      }

      //if conditional or subline start - add marker
      //if conditional or subline end - add end marker
      //don't add subline markers if in conditional block

      //use iconography instead of words
      line = line.replaceAll("Target", "%target%");

      retVal.add(line);
    }
    if(isReallySubLine && !isConditional){
      retVal.add("[subLineEnd]");
    }
    return retVal;
  }

  static void buildFHStyleBackgrounds(List<Widget> lines, List<InlineSpan> lastLineTextPartList, TextAlign textAlign, double scale,
      bool isInRow, bool isInColumn, bool isColumnInRow, List<Widget> widgetsInColumn, List<Widget> widgetsInRow) {
    List<InlineSpan> list1 = [];
    List<List<InlineSpan>> list2 = [];
    bool conditional = false;
    for (int i = 0; i < lastLineTextPartList.length; i++){
      if(lastLineTextPartList[i].toPlainText().contains("[subLineStart]")) {
        list1 = lastLineTextPartList.sublist(0,i);
        List<InlineSpan> tempSpanList = [];
        for (int j = i+1; j < lastLineTextPartList.length; j++) {
          if(lastLineTextPartList[j].toPlainText().contains("[lineBreak]")){
            list2.add(tempSpanList.toList());
            tempSpanList.clear();
          } else {
            tempSpanList.add(lastLineTextPartList[j]);
          }
        }
        list2.add(tempSpanList);
      }
      if(lastLineTextPartList[i].toPlainText().contains("[conditionalStart]")) {
        conditional = true;
        list1 = lastLineTextPartList.sublist(0,i);
        List<InlineSpan> tempSpanList = [];
        for (int j = i+1; j < lastLineTextPartList.length; j++) {
          if(lastLineTextPartList[j].toPlainText().contains("[lineBreak]")){
            list2.add(tempSpanList.toList());
            tempSpanList.clear();
          } else {
            tempSpanList.add(lastLineTextPartList[j]);
          }
        }
        list2.add(tempSpanList);
      }

    }

    Widget widget1 = Text.rich(
      textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even
      ),
      textAlign: textAlign,
      TextSpan(
        children: list1,
      ),
    );

    Widget widget2 = Container(
        decoration: BoxDecoration(
          //backgroundBlendMode: BlendMode.softLight,
          //border: Border.fromBorderSide(BorderSide(style: BorderStyle.solid, color: Colors.amber)),
            color: conditional? Colors.blue : Color(int.parse("9A808080", radix: 16)),
            borderRadius: BorderRadius.all(Radius.circular(6 * scale))

        ),
        padding: EdgeInsets.fromLTRB(3 * scale, 1 * scale, 3 * scale, 0.75 *scale),
        margin: EdgeInsets.only(left: 2 * scale),
        //child: Expanded(
            child: Column(
mainAxisSize: MainAxisSize.max,
            children: [
              if(list2.length > 0)
            Text.rich(
            textHeightBehavior: const TextHeightBehavior(
                leadingDistribution: TextLeadingDistribution.even
            ),
            textAlign: textAlign,
            TextSpan(
              children: list2[0],
            )),
          if(list2.length > 1)
            Text.rich(
                textHeightBehavior: const TextHeightBehavior(
                    leadingDistribution: TextLeadingDistribution.even
                ),
                textAlign: textAlign,
                TextSpan(
                  children: list2[1],
                )),
              if(list2.length > 2)
                Text.rich(
                    textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even
                    ),
                    textAlign: textAlign,
                    TextSpan(
                      children: list2[2],
                    )),
              if(list2.length > 3)
                Text.rich(
                    textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even
                    ),
                    textAlign: textAlign,
                    TextSpan(
                      children: list2[3],
                    )),


          //can't figure out why the builder does not work
          /*ListView.builder(
            itemCount: list2.length,
            itemBuilder: (context, index) => Text.rich(
              textHeightBehavior: const TextHeightBehavior(
                  leadingDistribution: TextLeadingDistribution.even
              ),
              textAlign: textAlign,
              TextSpan(
                children: list2[index],
              ),
          )
          )*/
        ]
        )
    //)
    );
    MainAxisAlignment alignment = MainAxisAlignment.center;
    if(textAlign == TextAlign.end) {
      alignment = MainAxisAlignment.end;
    }
    if(textAlign == TextAlign.start) {
      alignment = MainAxisAlignment.start;
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: alignment,
      children: [
        widget1,
        widget2
      ],
    );


    if(isInColumn && (!isInRow || isColumnInRow) ){
      widgetsInColumn.removeLast();
      widgetsInColumn.add(row);
    }else if (isInRow && (!isInColumn)){
      widgetsInRow.removeLast();
      widgetsInRow.add(row);
    }
    else {
      lines.removeLast();
      lines.add(row);
    }
  }

  static Widget createLines(List<String> strings, final bool left, final bool applyStats,final bool applyAll,
      final Monster monster, final CrossAxisAlignment alignment, final double scale) {
    String imageSuffix = "";
    bool frosthavenStyle = GameMethods.isFrosthavenStyle();
    if (frosthavenStyle) {
      imageSuffix = "_fh";
    }

    var shadow = Shadow(
        offset: Offset(1 * scale * 0.8, 1 * scale * 0.8),
        color: left ? Colors.white : Colors.black);
    var dividerStyle = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: 8 * 0.8 * scale,
        letterSpacing: 2 * 0.8 * scale,
        height: 0.7,
        shadows: [shadow]);

    var smallStyle = TextStyle(
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center ? 10 : 11) *
            0.8 *
            scale,
        //sizes are larger on stat cards
        height: 1,//0.85,
        shadows: [shadow]);
    var midStyle = TextStyle(
      //backgroundColor: Colors.amber,

        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center ? 11 : 12.7) *
            0.8 *
            scale,
        //sizes are larger on stat cards
        height: (alignment == CrossAxisAlignment.center ? 1: 0.8),// 0.9,
        shadows: [shadow]
    );
    var normalStyle = TextStyle(
        //maybe slightly bigger between chars space?
        fontFamily: 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center ? 15.7 : 14) *
            0.8 *
            scale,
        height: (alignment == CrossAxisAlignment.center) ? 1.1 : 1,// 0.8,
        shadows: [shadow]);

    var eliteStyle = TextStyle(
        //maybe slightly bigger between chars space?
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 15.7 * 0.8 * scale,
        height: 1.1,//0.8,
        shadows: [shadow]);

    var eliteSmallStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 10 * 0.8 * scale,
        height: 1,
        shadows: [shadow]);
    var eliteMidStyle = TextStyle(
        fontFamily: 'Majalla',
        color: Colors.yellow,
        fontSize: 11 * 0.8 * scale,
        height: 1.1,
        shadows: [shadow]);

    List<Widget> lines = [];
    List<String> localStrings = [];
    localStrings.addAll(strings);
    List<InlineSpan> lastLineTextPartList = [];


    if (frosthavenStyle) {
      localStrings = convertLinesToFH(localStrings);
    }

    //specialized layouts
    bool isInColumn = false;
    bool isInRow = false;
    bool isColumnInRow = false;
    List<Widget> widgetsInColumn = [];
    List<Widget> widgetsInRow = [];
    Widget column;
    Widget row;

    TextAlign textAlign = TextAlign.center;
    if (alignment == CrossAxisAlignment.start) {
      textAlign = TextAlign.start;
    }
    if (alignment == CrossAxisAlignment.end) {
      textAlign = TextAlign.end;
    }

    for (int i = 0; i < localStrings.length; i++) {
      String line = localStrings[i];
      String sizeToken = "";
      bool isRightPartOfLastLine = false;
      var styleToUse = normalStyle;
      List<InlineSpan> textPartList = [];

      if(line == "[subLineStart]"){
        //continue;
      }
      //handle FH layout with gray background for sub-lines
      if(line.contains("[subLineEnd]") || line.contains("[conditionalEnd]")){
        buildFHStyleBackgrounds(
          lines, lastLineTextPartList, textAlign, scale,
          isInRow, isInColumn, isColumnInRow, widgetsInColumn, widgetsInRow
        );
        continue;
      }

      //Note: this solution can only have one column in a row and no deeper nesting
      if(line == "[c]"){
        isInColumn = true;
        if(isInRow) {
          isColumnInRow = true;
        }
        continue;
      }
      if(line == "[/c]"){
        //end column  //handle the results
        isInColumn = false;
        column = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.max,
          children: widgetsInColumn.toList(),
        );
        widgetsInColumn = [];
        if(isColumnInRow) {
          widgetsInRow.add(column);
        }else {
          lines.add(column);
          if(i == localStrings.length-1){
            //this never happens -unless last line is a [/c]
            return createLinesColumn(alignment, lines);
          }
        }
        continue;
      }
      if(line == "[r]"){
        isInRow = true;
        //start row
        continue;
      }
      if(line == "[/r]"){
        //end row
        //end column  //handle the results
        isInRow = false;
        //if(widgetsInRow[0].toStringDeep())
        bool elementUse = false;
        for(var item in widgetsInRow) {
          String compare = item.toStringDeep();
          if(compare.contains(" : ") || compare.toLowerCase().contains("if") ) { //not a great solution
            elementUse = true;
          }
          if(compare.startsWith("Column")) { //is a column in row
            for(var colItem in (item as Column).children) {
              String compare = colItem.toStringDeep();
              if(compare.contains(" : ") || compare.toLowerCase().contains("if") ) { //not a great solution
                elementUse = true;
              }
            }
          }
        }
        row = Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, //todo: this was max. make sure the change doe snot f something up
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgetsInRow.toList(),
        );
        widgetsInRow =[];


        if(frosthavenStyle && elementUse) { //or conditional: is isforsthavenStyle and contains a %use%
          lines.add(Container(
            margin: EdgeInsets.all(2 * scale),
              child: DottedBorder(
              color: Colors.white,
              //borderType: BorderType.Rect,
              borderType: BorderType.RRect,
              radius: Radius.circular(10 * scale),
              //strokeCap: StrokeCap.round,
              padding: const EdgeInsets.all(0),
              dashPattern: [2 * scale, 1 * scale],

              strokeWidth: 0.6 * scale,
              child:  Container(
              decoration: BoxDecoration(
                //backgroundBlendMode: BlendMode.softLight,
                //border: Border.fromBorderSide(BorderSide(style: BorderStyle.solid, color: Colors.white)),
                  color: Color(int.parse("9A808080", radix: 16)),
                  borderRadius: BorderRadius.all(Radius.circular(10 * scale))

              ),
              padding: EdgeInsets.fromLTRB(3 * scale, 1 * scale, 3 * scale, 0.75 *scale),
              //margin: EdgeInsets.only(left: 2 * scale),
              //child: Expanded(
              child: row
          )))
          );
        }else {
          lines.add(row);
        }
        if(i == localStrings.length-1){ //error just a string compare
          return createLinesColumn(alignment, lines);
        }
        continue;
      }

      if (line.startsWith('¤')) {
        double scaleConstant =0.8 * 0.55; //this is because of the actual size of the assets
        if(line.substring(1) == "air"||
            line.substring(1) == "earth"||
            line.substring(1) == "ice"||
            line.substring(1) == "fire"||
            line.substring(1) == "light"||
            line.substring(1) == "dark"
        ) {
          //because we added new graphics for these that are bigger (todo: change this when creating new aoe graphic)
          scaleConstant *= 0.6;
        }
        Widget image =
        Image.asset(
          scale: 1.0/(scale * scaleConstant), //for some reason flutter likes scale to be inverted

          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.high,
          "assets/images/abilities/${line.substring(1)}.png",
        );
        //create pure picture, not a WidgetSpan (scale 5.5)
        if(isInColumn && (!isInRow || isColumnInRow) ){
          widgetsInColumn.add(image);
        }else if (isInRow && (!isInColumn)){
          widgetsInRow.add(image);
        }
        else {
          lines.add(image);
        }
        if(i == localStrings.length-1){
          return createLinesColumn(alignment, lines);
        }
        continue;
      }

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
          if(frosthavenStyle) {
            Widget image =
            Image.asset(
              scale: 1.0/(scale * 0.15), //for some reason flutter likes scale to be inverted
              //fit: BoxFit.fitHeight,
              height: 6 * scale,
              width: 50 * scale,
              filterQuality: FilterQuality.high,
              "assets/images/abilities/divider_fh.png",
            );
            //create pure picture, not a WidgetSpan (scale 5.5)
            if(isInColumn && (!isInRow || isColumnInRow) ){
              widgetsInColumn.add(image);
            }else if (isInRow && (!isInColumn)){
              widgetsInRow.add(image);
            }
            else {
              lines.add(image);
            }
            if(i == localStrings.length-1){
              return createLinesColumn(alignment, lines);
            }
            continue;
          }
        }
      }
      if (line.startsWith('^')) {
        sizeToken = '^';
        styleToUse = midStyle;
        line = line.substring(1, line.length);
      }
      if (applyStats) {
        List<String> statLines = _applyMonsterStats(line, sizeToken, monster, applyAll);
        line = statLines.removeAt(0);
        if (statLines.isNotEmpty) {
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
          //TODO: do for all conditions + jump.

          if (isIconPart) {
            //create token part
            String iconToken = line.substring(partStartIndex, i);
            String iconGfx = iconToken;
            if (left) {
              RegExp regEx = RegExp(
                  r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
              if (regEx.hasMatch(_tokens[iconToken]!) == true) {
                iconGfx += "_black";
              }
            }
            if (iconToken == "use") {
              //put use gfx on top of previous and add ':'
              WidgetSpan part = textPartList.removeLast() as WidgetSpan;
              Image lastImage = (part.child as Container).child as Image;
              textPartList.add(WidgetSpan(
                  //alignment: PlaceholderAlignment.top,
                  style: styleToUse, //this is wrong here
                  child: Container(
                    //color: Colors.amber,
                    //margin: margin,
                    child: Stack(
                      clipBehavior: Clip.none,
                    children: [
                      lastImage,
                      Positioned(
                        width: frosthavenStyle?  styleToUse.fontSize! * 1.2+ scale * 5 : styleToUse.fontSize! * 1.2,
                        bottom: 0,
                          left: frosthavenStyle? 2.8  * scale : 0, //why left?!

                          child: Image(
                        height: frosthavenStyle? styleToUse.fontSize! * 1.2 * 0.5: styleToUse.fontSize! * 1.2,
                        //width: frosthavenStyle? styleToUse.fontSize! * 1.2 * 0.5: styleToUse.fontSize! * 1.2,
                        //alignment: Alignment.topCenter,
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.high,
                        image:
                            AssetImage("assets/images/abilities/${iconGfx+imageSuffix}.png"),
                      ))
                    ],
                  ))));
              textPartList.add(TextSpan(
                  text: " : ", style: styleToUse));
            } else {
              double height = _getIconHeight(iconToken, styleToUse.fontSize!);
              if (addText) {
                String? iconTokenText = _tokens[iconToken];
                if (frosthavenStyle) {
                  iconTokenText = null;
                }
                textPartList
                    .add(TextSpan(text: iconTokenText, style: styleToUse));
              }
              bool mainLine = styleToUse == normalStyle || styleToUse == eliteStyle;
              EdgeInsetsGeometry margin =
                  _getMarginForToken(iconToken, height, mainLine, alignment, frosthavenStyle);
              if (iconToken == "move" && monster.type.flying) {
                iconGfx = "flying";
              }
              String imagePath = "assets/images/abilities/$iconGfx.png";
              if(imageSuffix.isNotEmpty) {
                if (File("assets/images/abilities/$iconGfx$imageSuffix.png").existsSync()) {
                  imagePath = "assets/images/abilities/$iconGfx$imageSuffix.png";
                }
              }
              Widget child = Image(
                //fit: BoxFit.contain,
                //could do funk stuff with the color value for cool effects maybe?
                height: height, //TODO: this causes lines to have variable height
                //alignment: Alignment.topCenter,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.high,
                image: AssetImage(imagePath),
              );
              child = Container(
                height: height,
                //color: Colors.amber,
                margin: margin,
                child: child,
              );

              //TODO: make a solid solution. not a house of cards.
              double wtf = 1;
              if(height == styleToUse.fontSize! * 1.2) { //is element height
                wtf = 1.8; //wtf for elements alignment
              }
              //wtf = 1;

              textPartList.add(WidgetSpan(
                  style: TextStyle(
                      fontSize: styleToUse.fontSize! * wtf),
                  //styleToUse, //don't ask (probably because height is 0.8
                  child: child));
            }
            isIconPart = false;
            addText = true;
          } else {
            //create part up to now if length more than 0
            if (i > 0 && partStartIndex < i) {
              String textPart = line.substring(partStartIndex, i);
              if (i > 0 && line[i - 1] == "|") {
                //voi ei. remove the | from output. would be nice to find better place to do this
                textPart = line.substring(partStartIndex, i - 1);
              }

              textPartList.add(TextSpan(text: textPart, style: styleToUse));
            }
            isIconPart = true;
          }
          partStartIndex = i + 1;
        }
        if (line[i] == "£") {
          //finish current part
          partStartIndex = i + 1;
          if (styleToUse == normalStyle) {
            styleToUse = eliteStyle;
          } else if (styleToUse == smallStyle) {
            styleToUse = eliteSmallStyle;
          } else if (styleToUse == midStyle) {
            styleToUse = eliteMidStyle;
          }
        }
        if (line[i] == "Å") {
          styleToUse = TextStyle(

            //backgroundColor: Colors.amber,
              fontFamily: 'Majalla',
              color: Colors.transparent,
              fontSize: 11 * 0.8 * scale,
              height: 1);
        }
      }

      if (partStartIndex < line.length) {
        String textPart = line.substring(partStartIndex, line.length);
        textPartList.add(TextSpan(text: textPart, style: styleToUse));
      }
      var text = Text.rich(
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even
        ),
        textAlign: textAlign,
        TextSpan(
          children: textPartList,
        ),
      );
      if (isRightPartOfLastLine) {
        if(isInColumn && (!isInRow || isColumnInRow) ){
          if (widgetsInColumn.isNotEmpty) {
            widgetsInColumn.removeLast();
          }
        }else if (isInRow && (!isInColumn)){
          if(widgetsInRow.isNotEmpty) {
            widgetsInRow.removeLast();
          }
        }
        else {
          lines.removeLast();
        }
        textPartList.insertAll(0, lastLineTextPartList);
        text = Text.rich(
          textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even
          ),
          textAlign: textAlign,
          TextSpan(
            children: textPartList,
          ),
        );
      }

      if (isInColumn && (!isInRow || isColumnInRow)) {
        widgetsInColumn.add(text);
      } else if (isInRow && (!isInColumn)) {
        widgetsInRow.add(text);
      }

      else {
        lines.add(text);
      }
      lastLineTextPartList = textPartList;
    }
    return createLinesColumn(alignment, lines);
  }
}
