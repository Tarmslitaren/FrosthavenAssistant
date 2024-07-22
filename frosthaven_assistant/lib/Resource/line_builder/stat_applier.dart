import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../Model/monster.dart';
import '../enums.dart';
import '../stat_calculator.dart';
import '../state/game_state.dart';

class StatApplier {
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
      if (sizeMod == "^" || sizeMod == "*" && item.length > 1) {
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
      return [line];
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
              item != "heal" &&
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
              item != "heal" &&
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
            newStartOfLine += "$value";
          }
        }
      }
    }

    //special case for incalculable and only elites (heed the pigs)
    if(elite != null && skipCalculation && showElite && !showNormal) {
      newStartOfLine += normalResult;
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
          eliteString += "$value";
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

  static List<String> applyMonsterStats(final String lineInput,
      String sizeToken, Monster monster, bool forceShowAll) {
    bool showElite = false;
    if (monster.isActive ||
        monster.monsterInstances.firstWhereOrNull(
                (element) => element.type == MonsterType.elite) !=
            null) {
      showElite = true;
    }
    bool showNormal = false;
    if (monster.isActive ||
        monster.monsterInstances.firstWhereOrNull(
                (element) => element.type != MonsterType.elite) !=
            null) {
      showNormal = true;
    }
    if (forceShowAll) {
      showElite = true;
      showNormal = true;
    }
    String line = lineInput;
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
              line[i] ==
                  'X' || //hax: X doesn't work in formula, but if a formula starts wit X it should bork. Hopefully there are no wild 'X's anywhere.
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
          if (val.contains(regExpNumbers) || val == "d") {
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
}
