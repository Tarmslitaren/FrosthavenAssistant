import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';

import '../Resource/enums.dart';
import '../Resource/game_state.dart';
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

  static double _getIconHeight(
      String iconToken, double height, bool isFrosthavenStyle) {
    if (iconToken == "air" ||
        iconToken == "earth" ||
        iconToken == "earthfire" ||
        iconToken == "fire" ||
        iconToken == "ice" ||
        iconToken == "dark" ||
        iconToken == "light" ||
        iconToken == "any") {
      //FH style: elements have same size as regular icons
      return isFrosthavenStyle ? height : height * 1.2;
    }
    if (iconToken.contains("aoe")) {
      return height * 2;
    }
    //if(shouldOverflow(isFrosthavenStyle, iconToken, true)) {
    //  return height * 1.2;
    //}
    return height;
  }

  static EdgeInsetsGeometry _getMarginForToken(String iconToken, double height,
      bool mainLine, CrossAxisAlignment alignment, bool isFrostHavenStyle) {
    double margin = 0.2;

    if (alignment != CrossAxisAlignment.center) {
      margin = 0.1;
    }
    if (isFrostHavenStyle) {
      margin = 0;
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
    if (iconToken == "pierce" ||
        iconToken == "target" ||
        iconToken == "curse" ||
        iconToken == "bless" ||
        iconToken == "curse" ||
        iconToken == "push" ||
        iconToken == "pull" ||
        iconToken.contains("poison") ||
        iconToken.contains("wound") ||
        iconToken == "infect" ||
        iconToken == "chill" ||
        iconToken == "disarm" ||
        iconToken == "immobilize" ||
        iconToken == "stun" ||
        iconToken == "muddle") {
      if (mainLine) {
        //smaller margins for secondary modifiers
        return const EdgeInsets.all(0);
      } else if (isFrostHavenStyle == true && iconToken != "target") {
        //need more margin around the over sized condition gfx
        return EdgeInsets.only(left: 0.25 * height, right: 0.25 * height);
      }
    }
    if (iconToken == "air" ||
        iconToken == "earth" ||
        iconToken == "earthfire" ||
        iconToken == "fire" ||
        iconToken == "ice" ||
        iconToken == "dark" ||
        iconToken == "light" ||
        iconToken == "light" ||
        iconToken == "use" ||
        iconToken == "any") {
      //this caused elements to not align well especially noticeable in case of use element to create element
      // return EdgeInsets.only(top: 0.19 * height); //since icons lager, need lager margin top (make margins in source files instead)
    }
    if (isFrostHavenStyle) {
      return EdgeInsets.zero;
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
      if (sizeMod == "^" || sizeMod == "*") {
        item = item.substring(1);
      }
      if (item.substring(0, 1) == "%") {
        //expects token to be first in line. is this ok?
        //parse item and then parse number;
        for (int i = 1; i < item.length; i++) {
          if (item[i] == '%') {
            String token = item.substring(1, i);
            int number = 0;
            if (i != item.length - 1) {
              for (int j = i + 2; j < item.length; j++) {
                if (item[j] == ' ' || j == item.length - 1) {
                  //need to find end of nr and ignore the rest
                  String nr = item.substring(i + 1, j + 1);
                  int? res = StatCalculator.calculateFormula(nr);
                  if (res != null) {
                    number = res;
                  } else {
                    if (kDebugMode) {
                      print(
                          "failed calculation for formula: ${nr}for token: $token");
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

  static double getTopPaddingForStyle(TextStyle style) {
    if(style.height! < 1) {
      return 0;
    }
    double height = style.fontSize!;
    bool markazi = style.fontFamily == "Markazi";
    if(markazi) {
      return height * 0.1;
    }
    return height * 0.15;
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
    if (!showElite && !showNormal) {
      return [line]; //?
    }

    List<String> retVal = [];
    List<String> tokens = [];
    List<String> eTokens = [];
    int normalValue = 0;
    int eliteValue = 0;
    bool skipCalculation = false; //in case un-calculable
    MonsterStatsModel? normal = monster.type.levels[monster.level.value].boss ??
        monster.type.levels[monster.level.value].normal;
    MonsterStatsModel? elite = monster.type.levels[monster.level.value].elite;
    if (lastToken == "attack") {
      int? calc = StatCalculator.calculateFormula(normal!.attack);
      if (calc != null) {
        normalValue = calc;
      } else {
        skipCalculation = true;
      }
      if (elite != null) {
        calc = StatCalculator.calculateFormula(elite.attack);
        if (calc != null) {
          eliteValue = calc;
        }
      }

      RegExp regEx =
          RegExp(r"(?=.*[a-z])"); //not sure why I do this. only letters?
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
    } else if (lastToken == "shield") {
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
      int? res = StatCalculator.calculateFormula("$formula+$normalValue");

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
    if (showNormal) {
      newStartOfLine += normalResult;
      if (!skipCalculation) {
        for (var item in tokens) {
          newStartOfLine += "|$item";
          //add nr if applicable
          String key = item.substring(1, item.length - 1);
          int value = normalTokens[key]!;
          if (value > 0) {
            newStartOfLine += " $value";
          }
        }
      }
    }

    if (elite != null && !skipCalculation && showElite) {
      if (showNormal) {
        newStartOfLine += "/";
      }
      retVal.add(newStartOfLine);

      int eliteResult =
          StatCalculator.calculateFormula("$formula+$eliteValue")!;
      if (eliteResult < 0) {
        eliteResult = 0;
      }
      String eliteString = "!$sizeModifier£$eliteResult";
      for (var item in eTokens) {
        eliteString += "|$item";

        //add nr if applicable
        String key = item.substring(1, item.length - 1);
        int value = eliteTokens[key]!;
        if (value > 0) {
          eliteString += " $value";
        }
      }
      retVal.add(eliteString);
    } else {
      retVal.add(newStartOfLine);
    }
    if (endIndex < line.length) {
      String leftOver =
          "!$sizeModifier${line.substring(endIndex + 1, line.length)}";

      //retVal.addAll(applyMonsterStats(leftOver, sizeToken, monster));
      retVal.add(leftOver);
    }
    return retVal;
  }

  static List<String> _applyMonsterStats(final String lineInput,
      String sizeToken, Monster monster, bool forceShowAll) {
    bool showElite = monster.monsterInstances.value.isNotEmpty &&
            monster.monsterInstances.value[0].type == MonsterType.elite ||
        monster.isActive;
    bool showNormal = monster.monsterInstances.value.isNotEmpty &&
            monster.monsterInstances.value.last.type != MonsterType.elite ||
        monster.isActive;
    if (forceShowAll) {
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
          //for a formula to work (outside of plain C or L) it must either be modifying a token value or be 3+ chars long
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
            if (result != null) {
              if (result < 0) {
                //just some nicety. probably never applies
                result = 0;
              }
              line = line.replaceRange(
                  startIndex, endIndex + 1, result.toString());
            }
          }
        }
      }
    }

    return [line];
  }

  static Widget createLinesColumn(
      CrossAxisAlignment alignment, List<Widget> lines) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.max,
        children: lines);
  }

  static List<String> convertLinesToFH(List<String> lines, bool applyStats) {
    //move lines up when they should
    //add container markers here as well
    List<String> retVal = [];
    bool isSubLine =
        false; //marked potential start of sub line after a mainline end
    bool isReallySubLine = false; //when entering a definite sub line
    bool isConditional = false;
    bool isElementUse = false;
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line == "[r]" && lines[i + 1].contains('%use')) {
        isElementUse = true;
      }
      if (line == "[r]" &&
          (lines[i + 1].contains('%use') ||
              lines[i + 1].toLowerCase().contains('if ') || lines[i + 1].contains('On ') ||
              (lines.length > i + 2 &&
                  lines[i + 2].toLowerCase().contains('if ')|| lines[i + 1].contains('On ')))) {
        isConditional = true;
      }
      if (line == "[/r]" && isConditional) { //TODO: add instead a [conditionalDone] tag
        isConditional = false;
        isElementUse = false;
      }

      line = line.replaceAll("Affect", "Target");
      if (!applyStats) {
        line = line.replaceAll(" - ", "-");
        line = line.replaceAll(" + ", "+");
      }
      line = line.replaceAll("% ", "%"); //oh oh.

      //the affect keyword is presumably because in base gloomhaven you can only target enemies.
      // this is changed already in JotL.

      if (line.startsWith("*")) {
        //now for both * and *..... potential problems?
        //reset
        if (isReallySubLine) {
          //&& !isConditional
          retVal.add("[subLineEnd]");
        }
        isReallySubLine = false;
        isSubLine = false;
        isConditional = false;
        isElementUse = false;
      }

      if (line.startsWith("^") && isSubLine) {
        //&& !isConditional
        if (!isReallySubLine && (!isConditional || isElementUse)) {
          //!isConditional
          retVal.add("[subLineStart]");
          isReallySubLine = true;

          //too wide? remove whitespace between icon and value. only for sub lines?
          //line = line.replaceAll("% ", "%");
        }
        //check if match right align issues
        if (line[1] == '%' ||
            //these are all very... assuming.
            line.startsWith("^Self") ||
            line.startsWith("^-") || //useful for element use add effects
            line.startsWith("^+") ||
            line.startsWith("^Advantage") ||
            //only target on same line for non valued tokens
            (line.startsWith("^Target") && lines[i - 1].contains('%push%')) ||
            (line.startsWith("^Target") && lines[i - 1].contains('%pull%')) ||
            (line.startsWith("^Target") &&
                lines[i - 1].startsWith('%') &&
                lines[i - 1].endsWith(
                    '%')) || //this is to add sub line after a lone condition
            (line.startsWith("^Target") &&
                lines[i - 1].startsWith('^%') &&
                lines[i - 1].endsWith(
                    '%')) || //you will not want a linebreak after a lone poison sub line
            line.startsWith("^all") ||
            line.startsWith("^All") &&
                !line.startsWith("^All attacks") &&
                !line.startsWith("^All targets")) {
          //make bigger icon and text in element use block
          //TODO: make sure this doesnt crash if element use on first line
          if (isElementUse && (!lines[i - 2].contains("[c]")) && !line.startsWith("^Target")
              && !line.startsWith("^all")
          ) {
            //ok, so if there is a subline, then there has to be a [c]
            line = line.substring(1); //make first sub line into main line
            if (retVal.last == "[subLineStart]") {
              retVal.removeLast();
            }
            isReallySubLine = false;
          }
          line = "!$line";
          line = line.replaceFirst("Self", "self");
          line = line.replaceFirst("All", "all");

          //TODO: add commas if needed

          if (retVal.last == "[subLineStart]") {
            retVal.last = "![subLineStart]";
          } else {
            //line = "!^ " + line.substring(2); //adding space
          }
        }

        if (retVal.last.endsWith("%") && line.endsWith("adjacent enemy")) {
          //blood ooze 62 hack
          retVal[retVal.length - 2] = "[subLineStart]";
        }
      }
      if (line.startsWith("^") && isReallySubLine) {
        //I know.
        //we add a line breaker at same time as we attach line to last,
        // because we only look at lastLineTextPartList later
        if (retVal.last != "[subLineStart]") {
          retVal.add("!^[lineBreak]");
        }
        line = "!$line";
      } else if (line.startsWith("!") ||
          line.startsWith("*") ||
          line.startsWith("^")) {
        //ignore
      } else {
        // if(line != "[c]" && line != "[r]"){
        if (!isSubLine) {
          isSubLine = true;
        } else {
          if (isReallySubLine) {
            //&&!isConditional
            retVal.add("[subLineEnd]");
            isReallySubLine = false;
            isSubLine = false;
          }
        }
        // }
      }

      //if conditional or sub line start - add marker
      //if conditional or sub line end - add end marker
      //don't add sub line markers if in conditional block

      //use iconography instead of words
      line = line.replaceAll("Target", "%target%");

      retVal.add(line);
    }
    if (isReallySubLine && (!isConditional || isElementUse)) {
      //&& !isConditional
      retVal.add("[subLineEnd]");
    }
    return retVal;
  }

  static bool shouldOverflow(
      bool frosthavenStyle, String iconToken, bool mainLine) {
    return /*!mainLine &&*/ frosthavenStyle &&
        ((iconToken == "pierce" ||
            iconToken == "target" ||
            iconToken == "curse" ||
            iconToken == "bless" ||
            iconToken == "invisible" ||
            iconToken == "strengthen" ||
            iconToken == "curse" ||
            iconToken == "push" ||
            iconToken == "pull" ||
            iconToken.contains("poison") ||
            iconToken.contains("wound") ||
            iconToken == "infect" ||
            iconToken == "chill" ||
            iconToken == "disarm" ||
            iconToken == "immobilize" ||
            iconToken == "stun" ||
            iconToken == "muddle"));
  }

  static void buildFHStyleBackgrounds(
      List<Widget> lines,
      List<Widget> lastLineTextPartList,
      TextAlign textAlign,
      MainAxisAlignment rowMainAxisAlignment,
      double scale,
      bool isInRow,
      bool isInColumn,
      bool isColumnInRow,
      List<Widget> widgetsInColumn,
      List<Widget> widgetsInRow) {
    List<Widget> list1 = [];
    List<List<Widget>> list2 = [];
    bool conditional = false;
    for (int i = 0; i < lastLineTextPartList.length; i++) {
      Widget part = lastLineTextPartList[i];
      if(part is Container) {
        if (part.child! is Text &&
            (part.child as Text).data!.contains("[subLineStart]")) {
          list1 = lastLineTextPartList.sublist(0, i);
          List<Widget> tempSpanList = [];
          for (int j = i + 1; j < lastLineTextPartList.length; j++) {
            Widget part2 = lastLineTextPartList[j];
            if (part2 is Container && part2.child is Text && (part2.child as Text).data!.contains("[lineBreak]")) {
              list2.add(tempSpanList.toList());
              tempSpanList.clear();
            } else {
              tempSpanList.add(lastLineTextPartList[j]);
            }
          }
          list2.add(tempSpanList);
        }
      }
      if (part is Container && part.child is Text && (part.child as Text).data!.contains("[conditionalStart]")) {
        conditional = true;
        list1 = lastLineTextPartList.sublist(0, i);
        List<Widget> tempSpanList = [];
        for (int j = i + 1; j < lastLineTextPartList.length; j++) {
          Widget part2 = lastLineTextPartList[j];
          if (part2 is Container && part2.child is Text && (part2.child as Text).data!.contains("[lineBreak]")) {
            list2.add(tempSpanList.toList());
            tempSpanList.clear();
          } else {
            tempSpanList.add(lastLineTextPartList[j]);
          }
        }
        list2.add(tempSpanList);
      }
    }

    /*Widget widget1 = Text.rich(
      textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even),
      textAlign: textAlign,
      TextSpan(
        children: list1,
      ),
    );*/
    Row widget1 = Row(children: list1);

    Widget widget2 = Container(
        decoration: BoxDecoration(
            color: conditional
                ? Colors.blue
                : Color(int.parse("9A808080", radix: 16)),
            borderRadius: BorderRadius.all(Radius.circular(6 * scale))),
        padding: EdgeInsets.fromLTRB(
            2 * scale, 0.35 * scale, 2.5 * scale, 0.2625 * scale),
        margin: EdgeInsets.only(left: 2 * scale),
        //child: Expanded(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          if (list2.isNotEmpty) Row(children: list2[0]),
          if (list2.length > 1)
            Row(
              children: list2[1],
            ),
          if (list2.length > 2)
            Row(
              children: list2[2],
            ),
          if (list2.length > 3)
            Row(
              children: list2[3],
            )

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
        ])
        //)
        );
    MainAxisAlignment alignment = MainAxisAlignment.center;
    if (textAlign == TextAlign.end) {
      alignment = MainAxisAlignment.end;
    }
    if (textAlign == TextAlign.start) {
      alignment = MainAxisAlignment.start;
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: rowMainAxisAlignment,
      children: [widget1, widget2],
    );

    if (isInColumn && (!isInRow || isColumnInRow)) {
      widgetsInColumn.removeLast();
      widgetsInColumn.add(row);
    } else if (isInRow && (!isInColumn)) {
      if (widgetsInRow.isNotEmpty) {
        widgetsInRow.removeLast();
      }
      widgetsInRow.add(row);
    } else {
      lines.removeLast();
      lines.add(row);
    }
  }

  static String getAllTextInWidget(Widget widget) {
    String retVal = "";
    if(widget is Row) {
      for(Widget item in widget.children) {
        retVal += getAllTextInWidget(item);
      }
    }
    else if(widget is Column) {
      for(Widget item in widget.children) {
        retVal += getAllTextInWidget(item);
      }
    }
    else if (widget is Container && widget.child != null) {
      retVal += getAllTextInWidget(widget.child!);
    } else if (widget is Text) {
      retVal += widget.data!;
    }

    return retVal;
  }

  static Widget createLines(
      List<String> strings,
      final bool left,
      final bool applyStats,
      final bool applyAll,
      final Monster monster,
      final CrossAxisAlignment alignment,
      final double scale) {
    String imageSuffix = "";
    bool frosthavenStyle = GameMethods.isFrosthavenStyle();
    if (frosthavenStyle) {
      imageSuffix = "_fh";
    }
    MainAxisAlignment rowMainAxisAlignment = MainAxisAlignment.center;
    if (alignment == CrossAxisAlignment.start) {
      rowMainAxisAlignment = MainAxisAlignment.start;
    }
    if (alignment == CrossAxisAlignment.end) {
      rowMainAxisAlignment = MainAxisAlignment.end;
    }

    var shadow = Shadow(
      offset: Offset(0.4 * scale, 0.4 * scale),
      color: left ? Colors.black54 : Colors.black87,
      blurRadius: 1 * scale,
    );
    var dividerStyle = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: 8 * 0.8 * scale,
        letterSpacing: 2 * 0.8 * scale,
        height: 0.7,
        shadows: [shadow]);

    var dividerStyleExtraThin = TextStyle(
        fontFamily: 'Majalla',
        leadingDistribution: TextLeadingDistribution.proportional,
        color: left ? Colors.black : Colors.white,
        fontSize: 6 * 0.8 * scale,
        letterSpacing: 2 * 0.8 * scale,
        height: 0.1,
        shadows: [shadow]);

    var smallStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center ? 8 : 8.8) * scale,
        //sizes are larger on stat cards
        height: 1,
       // backgroundColor: Colors.amber,
        //0.85,
        shadows: [shadow]);
    var midStyle = TextStyle(
        //backgroundColor: Colors.greenAccent,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center
                ? frosthavenStyle
                    ? 7.52
                    : 8.8
                : 10.16) *
            scale,
        //sizes are larger on stat cards
        height: (alignment == CrossAxisAlignment.center ? 1 :
        1//0.8
        ),
        // 0.9,
        shadows: [shadow]);
    var normalStyle = TextStyle(
        //maybe slightly bigger between chars space?
        leadingDistribution: TextLeadingDistribution.even,
        textBaseline: TextBaseline.alphabetic,
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
       // backgroundColor: Colors.lightGreen,
        fontSize: (alignment == CrossAxisAlignment.center
                ? frosthavenStyle
                    ? 13.1
                    : 12.56
                : 11.2) *
            scale,
        height: (alignment == CrossAxisAlignment.center)
            ? frosthavenStyle
                ? 1//0.84
                : 1//0.5
            : frosthavenStyle? 1//0.84
            :1,// 0.5,
        //height is really low for gh style due to text not being center aligned in font - so to force to center the height is reduced. this is a shitty solution to a shitty problem.
        // 0.84,

        shadows: [shadow]);

    var eliteStyle = TextStyle(
        //backgroundColor: Colors.lightGreen,
        leadingDistribution: TextLeadingDistribution.even,
        //textBaseline: TextBaseline.alphabetic,
        //maybe slightly bigger between chars space?
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle ? 13.1 * scale : 12.56 * scale,
        height: 1,// frosthavenStyle ? 0.84 : 0.5,
        //0.8,
        shadows: [shadow]);

    var eliteSmallStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: 8 * scale,
        height: 1,
        shadows: [shadow]);
    var eliteMidStyle = TextStyle(
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: Colors.yellow,
        fontSize: frosthavenStyle ? 7.52 * scale : 8.8 * scale,
        height: 1,
        shadows: [shadow]);

    var midStyleSquished = TextStyle(
      //backgroundColor: Colors.greenAccent,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
        color: left ? Colors.black : Colors.white,
        fontSize: (alignment == CrossAxisAlignment.center
            ? frosthavenStyle
            ? 7.52
            : 8.8
            : 10.16) *
            scale,
        //sizes are larger on stat cards
        height: (alignment == CrossAxisAlignment.center ? 0.8 :
        0.8
        ),
        // 0.9,
        shadows: [shadow]);

    List<Widget> lines = [];
    List<String> localStrings = [];
    localStrings.addAll(strings);
    //List<InlineSpan> lastLineTextPartList = [];
    List<Widget> lastLineTextPartListRowContent = [];

    if (frosthavenStyle) {
      localStrings = convertLinesToFH(localStrings, applyStats);
    }

    //specialized layouts
    bool isInColumn = false;
    bool isInRow = false;
    bool isColumnInRow = false;
    List<Widget> widgetsInColumn = [];
    List<Widget> widgetsInRow = [];
    Widget column;

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
      //List<InlineSpan> textPartList = [];
      List<Widget> textPartListRowContent = [];

      if (line == "[subLineStart]") {
        //continue;
      }
      //handle FH layout with gray background for sub-lines
      if (line.contains("[subLineEnd]")) {
        buildFHStyleBackgrounds(
            lines,
            lastLineTextPartListRowContent,
            textAlign,
            rowMainAxisAlignment,
            scale,
            isInRow,
            isInColumn,
            isColumnInRow,
            widgetsInColumn,
            widgetsInRow);
        continue;
      }

      //Note: this solution can only have one column in a row and no deeper nesting
      if (line == "[c]") {
        isInColumn = true;
        if (isInRow) {
          isColumnInRow = true;
        }
        continue;
      }
      if (line == "[/c]") {
        //end column  //handle the results
        isInColumn = false;
        column = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.max,
          children: widgetsInColumn.toList(),
        );
        widgetsInColumn = [];
        if (isColumnInRow) {
          widgetsInRow.add(column);
        } else {
          lines.add(column);
          if (i == localStrings.length - 1) {
            //this never happens -unless last line is a [/c]
            return createLinesColumn(alignment, lines);
          }
        }
        continue;
      }
      if (line == "[r]") {
        isInRow = true;
        //start row
        continue;
      }
      if (line == "[/r]") {
        //end row
        //end column  //handle the results
        isInRow = false;
        //if(widgetsInRow[0].toStringDeep())

        /////start the dotted hack
        bool elementUse = false;
        bool conditional = false;
        bool columnHack = false;
        //this is used since there is a bug where if there is a [r] %element%%use% [c] ... [/c][/r] then the use is drawn twice. the bug is likely higher up
        String texts = "";
        for (var item in widgetsInRow) {
          texts += getAllTextInWidget(item);
        }
        if (texts.contains(" :")) {
          elementUse = true;
          conditional = true;
        }
        if (texts.toLowerCase().contains("if ") || texts.contains('On ')) {
          conditional = true;
        }
        if(texts.lastIndexOf(" :") != texts.indexOf(" :")) {
          columnHack = true;
        }

        Row row = Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          //todo: this was max. make sure the change does not f something up
          mainAxisAlignment: rowMainAxisAlignment,
          children:
              columnHack ? widgetsInRow.sublist(1) : widgetsInRow.toList(),
        );
        widgetsInRow = [];

        if (frosthavenStyle && conditional) {
          //or conditional: is isFrosthavenStyle and contains a %use%
          lines.add(Container(
              margin: EdgeInsets.all(2 * scale),
              //alignment: Alignment.bottomCenter,
              child: DottedBorder(
                  color: Colors.white,
                  //borderType: BorderType.Rect,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(10 * scale),
                  //strokeCap: StrokeCap.round,
                  padding: const EdgeInsets.all(0),
                  dashPattern: [2 * scale, 1 * scale],
                  strokeWidth: 0.6 * scale,
                  child: Container(
                      decoration: BoxDecoration(
                          //backgroundBlendMode: BlendMode.softLight,
                          //border: Border.fromBorderSide(BorderSide(style: BorderStyle.solid, color: Colors.white)),
                          color: Color(int.parse("9A808080", radix: 16)),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10 * scale))),
                      //TODO: should the padding be dependant on nr of lines?
                      padding: EdgeInsets.fromLTRB(
                          elementUse ? 1 * scale : 3 * scale,
                          0.25 * scale,
                          3 * scale,
                          0.2625 * scale),
                      //margin: EdgeInsets.only(left: 2 * scale),
                      //child: Expanded(
                      child: row))));
        } else {
          lines.add(row);
        }
        if (i == localStrings.length - 1) {
          //error just a string compare
          return createLinesColumn(alignment, lines);
        }
        continue;
      }

      if (line.startsWith('¤')) {
        double scaleConstant =
            0.8 * 0.55; //this is because of the actual size of the assets
        if (line.substring(1) == "air" ||
            line.substring(1) == "earth" ||
            line.substring(1) == "earthfire" ||
            line.substring(1) == "ice" ||
            line.substring(1) == "fire" ||
            line.substring(1) == "light" ||
            line.substring(1) == "any" ||
            line.substring(1) == "dark") {
          //because we added new graphics for these that are bigger (todo: change this when creating new aoe graphic)
          scaleConstant *= 0.6;
        }
        Widget image = Image.asset(
          scale: 1.0 / (scale * scaleConstant),
          //for some reason flutter likes scale to be inverted
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.high,
          "assets/images/abilities/${line.substring(1)}.png",
        );
        //create pure picture, not a WidgetSpan (scale 5.5)
        if (isInColumn && (!isInRow || isColumnInRow)) {
          widgetsInColumn.add(image);
        } else if (isInRow && (!isInColumn)) {
          widgetsInRow.add(image);
        } else {
          lines.add(image);
        }
        if (i == localStrings.length - 1) {
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
        if (line.startsWith("....") ||line.startsWith("*....")) {
          styleToUse = dividerStyle;
          if(line.startsWith('*')){
            line = line.substring(1, line.length);
            styleToUse = dividerStyleExtraThin;
          }

          if (frosthavenStyle) {
            Widget image = Image.asset(
              scale: 1.0 / (scale * 0.15),
              //for some reason flutter likes scale to be inverted
              //fit: BoxFit.fitHeight,
              height: 6 * scale,
              width: 50 * scale,
              filterQuality: FilterQuality.high,
              "assets/images/abilities/divider_fh.png",
            );
            //create pure picture, not a WidgetSpan (scale 5.5)
            if (isInColumn && (!isInRow || isColumnInRow)) {
              widgetsInColumn.add(image);
            } else if (isInRow && (!isInColumn)) {
              widgetsInRow.add(image);
            } else {
              lines.add(image);
            }
            if (i == localStrings.length - 1) {
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
        if(line.startsWith('^')) { //double ^^ : no means no, you bastard!
          styleToUse = midStyleSquished;
          line = line.substring(1, line.length);
        }
      }
      if (applyStats) {
        List<String> statLines =
            _applyMonsterStats(line, sizeToken, monster, applyAll);
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
              // WidgetSpan part = textPartList.removeLast() as WidgetSpan;
              Widget part = textPartListRowContent.removeLast();
              Container container = part as Container;
              Image lastImage;
              if (container.child is Image) {
                lastImage = container.child as Image;
              } else {
                lastImage = (container.child as OverflowBox).child as Image;
              }
              //Image lastImage = ((part.child as Container).child as OverflowBox).child as Image;
              textPartListRowContent.add(Container(
                 // color: Colors.amber,
                  //margin: margin,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      lastImage,
                      Positioned(
                          width: frosthavenStyle
                              ? styleToUse.fontSize! * 0.8 + scale * 5
                              : styleToUse.fontSize! * 1.2,
                          bottom: 0,
                          left: frosthavenStyle ? 2.8 * scale : 0,
                          //why left?!

                          child: Image(
                            height: frosthavenStyle
                                ? styleToUse.fontSize! * 1 * 0.5
                                : styleToUse.fontSize! * 1.2,
                            //width: frosthavenStyle? styleToUse.fontSize! * 1.2 * 0.5: styleToUse.fontSize! * 1.2,
                            //alignment: Alignment.topCenter,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.high,
                            image: AssetImage(
                                "assets/images/abilities/${iconGfx + imageSuffix}.png"),
                          ))
                    ],
                  )));
              textPartListRowContent.add(Text(frosthavenStyle ? " :" : " : ",
                  style: TextStyle(
                      //maybe slightly bigger between chars space?
                      fontFamily: frosthavenStyle ? 'Markazi' : 'Majalla',
                      color: left ? Colors.black : Colors.white,
                     // backgroundColor: Colors.amber,
                      fontSize:
                          (alignment == CrossAxisAlignment.center ? 12 : 12) *
                              0.8 *
                              scale,
                      height: (alignment == CrossAxisAlignment.center)
                          ? frosthavenStyle
                              ? 1
                              : 1.1
                          : 1,
                      // 0.8,

                      shadows: [
                        shadow
                      ]))); //use majalla even for FH style on this one
            } else {
              double height = _getIconHeight(
                  iconToken, styleToUse.fontSize!, frosthavenStyle);
              if (addText) {
                String? iconTokenText = _tokens[iconToken];
                if (frosthavenStyle) {
                  iconTokenText = null;
                } else if (iconTokenText != null) {
                  textPartListRowContent
                      .add(Container(
                   // color: Colors.red,
                    padding: EdgeInsets.only(top: getTopPaddingForStyle(styleToUse)),
                      child:Text(iconTokenText!, style: styleToUse)));
                }
              }
              bool mainLine =
                  styleToUse == normalStyle || styleToUse == eliteStyle;
              EdgeInsetsGeometry margin = _getMarginForToken(
                  iconToken, height, mainLine, alignment, frosthavenStyle);
              if (iconToken == "move" && monster.type.flying) {
                iconGfx = "flying";
              }
              String imagePath = "assets/images/abilities/$iconGfx.png";
              if (imageSuffix.isNotEmpty) {
                if (File("assets/images/abilities/$iconGfx$imageSuffix.png")
                    .existsSync()) {
                  imagePath =
                      "assets/images/abilities/$iconGfx$imageSuffix.png";
                }
              }
              bool overflow =
                  shouldOverflow(frosthavenStyle, iconGfx, mainLine);
              double heightMod = mainLine
                  ? 1
                  : 1.35 *
                      1.15; //to make sub line conditions have larger size and overflow on FH style
              Widget child = Image(
                //fit: BoxFit.contain,
                //could do funk stuff with the color value for cool effects maybe?
                height: overflow ? height * heightMod : height,
                //this causes lines to have variable height if height set to less than 1
                //alignment: Alignment.topCenter,
                fit: BoxFit.fitHeight,
                //alignment: Alignment.topLeft,
                filterQuality: FilterQuality.high,
                image: AssetImage(imagePath),
              );
              child = Container(
                 // color: Colors.blue,
                  height: height,
                  width: overflow ? height : null,
                  margin: margin,
                  clipBehavior: Clip.none,
                  child: overflow
                      ? OverflowBox(
                          minWidth: 0.0,
                          minHeight: 0.0,
                          maxHeight: double.infinity,
                          // height * heightMod,
                          maxWidth: double.infinity,
                          // height * heightMod,
                          child: child,
                        )
                      : child);

              //TODO: make a solid solution. not a house of cards.
              double wtf = 1;
              if (height == styleToUse.fontSize! * 1.2) {
                //is element height
                wtf = 1.8; //wtf for elements alignment
              }
              //wtf = 1;

              textPartListRowContent.add(child);
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

              textPartListRowContent.add(Container(
                //  color: Colors.red,
                  padding: EdgeInsets.only(top: getTopPaddingForStyle(styleToUse)),
                  child:
                  Text(textPart, style: styleToUse)));
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
        textPartListRowContent.add(Container(
         //   color: Colors.red,
            padding: EdgeInsets.only(top: getTopPaddingForStyle(styleToUse)),
            child:Text(textPart, style: styleToUse)));
      }

      //TODO: use rows instead of Text.rich

      /*var text = Text.rich(
        //style: styleToUse,
        textHeightBehavior: const TextHeightBehavior(
            leadingDistribution: TextLeadingDistribution.even),
        textAlign: textAlign,
        TextSpan(
          //style: styleToUse,
          children: textPartList,
        ),
      );*/
      Row row = Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: rowMainAxisAlignment,
          children: textPartListRowContent);

      if (isRightPartOfLastLine) {
        if (isInColumn && (!isInRow || isColumnInRow)) {
          if (widgetsInColumn.isNotEmpty) {
            widgetsInColumn.removeLast();
          }
        } else if (isInRow && (!isInColumn)) {
          if (widgetsInRow.isNotEmpty) {
            widgetsInRow.removeLast();
          }
        } else {
          lines.removeLast();
        }
        textPartListRowContent.insertAll(0, lastLineTextPartListRowContent);
        /*text = Text.rich(
          style: styleToUse,
          textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even),
          textAlign: textAlign,
          TextSpan(
            style: styleToUse,
            children: textPartList,
          ),
        );*/
        row = Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: rowMainAxisAlignment,
            children: textPartListRowContent);
      }

      if (isInColumn && (!isInRow || isColumnInRow)) {
        widgetsInColumn.add(row);
      } else if (isInRow && (!isInColumn)) {
        widgetsInRow.add(row);
      } else {
        lines.add(row);
      }
      // lastLineTextPartList = textPartList;
      lastLineTextPartListRowContent = textPartListRowContent;
    }
    return createLinesColumn(alignment, lines);
  }
}
