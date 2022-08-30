
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/stat_calculator.dart';

import '../Resource/enums.dart';
import '../Resource/game_state.dart';
import '../Resource/settings.dart';
import '../services/service_locator.dart';

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
      bool mainLine, CrossAxisAlignment alignment) {
    double margin = 0.2;
    if (alignment != CrossAxisAlignment.center) {
      margin = 0.1;
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
    iconToken == "any"
    ) {
      return EdgeInsets.only(top: 0.19 * height); //since icons lager, need lager margin top
    }
    return EdgeInsets.only(left: 0.1 * height, right: 0.1 * height);
    return EdgeInsets.zero;
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
              item != "jump") {
            tokens.add("%$item%");
          }
        }
      }
      for (var item in eliteTokens.keys) {
        if (regEx.hasMatch(item) == true) {
          if (item != "shield" &&
              item != "retaliate" &&
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

  static Widget createLines(List<String> strings, bool left, bool applyStats, bool applyAll,
      Monster monster, CrossAxisAlignment alignment, double scale) {
    //applyStats = false;
    bool frosthavenStyle = getIt<Settings>().style.value == Style.frosthaven ||
        getIt<Settings>().style.value == Style.original && getIt<GameState>().currentCampaign.value == "Frosthaven";
    //TODO:more generic solution for coming campaigns with frosthaven style.
    String imageSuffix = "";
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
        shadows: [shadow]);
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

    //specialized layouts
    bool isInColumn = false;
    bool isInRow = false;
    bool isColumnInRow = false;
    bool isRowInColumn = false;
    List<Widget> widgetsInColumn = [];
    List<Widget> widgetsInRow = [];
    Widget column;
    Widget row;

    for (int i = 0; i < localStrings.length; i++) {
      String line = localStrings[i];
      String sizeToken = "";
      bool isRightPartOfLastLine = false;
      var styleToUse = normalStyle;
      List<InlineSpan> textPartList = [];

      //Note: this solution can only have one row in a column or one column in a row and no deeper nesting
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
            //TODO: remove - this never happens
            return createLinesColumn(alignment, lines);
          }
        }
        continue;
      }
      if(line == "[r]"){
        isInRow = true;
        if(isInColumn) {
          isRowInColumn = true;
        }
        //start row
        continue;
      }
      if(line == "[/r]"){
        //end row
        //end column  //handle the results
        isInRow = false;
        row = Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center, //TODO evaluate if this or center with margins on parts is better (probably center)
          children: widgetsInRow.toList(),
        );
        widgetsInRow =[];
        if(isRowInColumn) {
          widgetsInColumn.add(row);
        } else {
          lines.add(row);
          if(i == localStrings.length-1){ //error just a string compare
            return createLinesColumn(alignment, lines);
          }
        }
        continue;
      }
      if (line.startsWith('¤')) {
        Widget image =
        Image.asset(
          scale: 1.0/(scale * 0.8 * 0.55), //for some reason flutter likes scale to be inverted

          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.high,
          "assets/images/abilities/${line.substring(1)}.png",
        );
        //create pure picture, not a WidgetSpan (scale 5.5)
        if(isInColumn && (!isInRow || isColumnInRow) ){
          widgetsInColumn.add(image);
        }else if (isInRow && (!isInColumn|| isRowInColumn)){
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
              filterQuality: FilterQuality.high,
              "assets/images/abilities/divider_fh.png",
            );
            //create pure picture, not a WidgetSpan (scale 5.5)
            if(isInColumn && (!isInRow || isColumnInRow) ){
              widgetsInColumn.add(image);
            }else if (isInRow && (!isInColumn|| isRowInColumn)){
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
          //TODO: do for all conditions + jump.

          if (isIconPart) {
            //create token part
            String iconToken = line.substring(partStartIndex, i);
            String iconGfx = iconToken;
            if (left) {
              RegExp regEx = RegExp(
                  r"(?=.*[a-z])"); //black versions exist for all tokens containing lower case letters
              if (regEx.hasMatch(_tokens[iconToken]!) == true) {
                iconGfx += "-medium-black"; //TODO: rename black graphics
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
                  _getMarginForToken(iconToken, height, mainLine, alignment);
              if (iconToken == "move" && monster.type.flying) {
                iconGfx = "flying";
              }
              Widget child = Image(
                //fit: BoxFit.fill,
                //could do funk stuff with the color value for cool effects maybe?
                height: height, //TODO: this causes lines to have variable height
                //alignment: Alignment.topCenter,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.high,
                image: AssetImage("assets/images/abilities/$iconGfx.png"),
              );
              //TODO: may fine-tune the height of some/all icons here
              double fuu = 1;
              if(iconGfx == "poison" || iconGfx == "wound") {
                //fuu = 0.8;
                //margin = EdgeInsets.zero;
              }
              child = Container(
                height: height * fuu,
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
                      //height: styleToUse.height!*5,
                    //backgroundColor: Colors.blueGrey,
                     // textBaseline: TextBaseline.ideographic,
                   // decoration: TextDecoration.lineThrough,
                    //overflow: TextOverflow.visible,
                   // decorationColor: Colors.blueGrey,
                    //leadingDistribution: TextLeadingDistribution.even,

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
      TextAlign textAlign = TextAlign.center;
      if (alignment == CrossAxisAlignment.start) {
        textAlign = TextAlign.start;
      }
      if (alignment == CrossAxisAlignment.end) {
        textAlign = TextAlign.end;
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
          widgetsInColumn.removeLast();
        }else if (isInRow && (!isInColumn|| isRowInColumn)){
          widgetsInRow.removeLast();
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
        //lines.add(text);
      }
      if(isInColumn && (!isInRow || isColumnInRow) ){
        widgetsInColumn.add(text);
      }else if (isInRow && (!isInColumn|| isRowInColumn)){
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
