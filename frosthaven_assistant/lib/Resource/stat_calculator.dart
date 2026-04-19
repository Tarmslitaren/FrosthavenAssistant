import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Model/monster.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import 'game_methods.dart';

class StatCalculator {
  static int? calculateFormula(final Object stat, [GameState? gameState]) {
    if (stat is IntStatValue) return stat.value;
    if (stat is int) return stat;

    final String str;
    if (stat is FormulaStatValue) {
      str = stat.formula;
    } else if (stat is String) {
      str = stat;
    } else {
      return null;
    }

    final gs = gameState ?? getIt<GameState>();
    int C = GameMethods.getCurrentCharacterAmount(gameState: gs);
    final int minNrCharacters = 2;
    if (C < minNrCharacters) {
      C = minNrCharacters;
    }
    int L = gs.level.value;
    String formula = str.replaceAll("C", C.toString());
    formula = formula.replaceAll("L", L.toString());
    return eval(formula);
  }

  static int? eval(final String str) {
    return Parser(str).parse();
  }

  static bool evaluateCondition(final Object str) {
    return calculateFormula(str) == 1;
  }
}

class Parser {
  int pos = -1;
  late String ch; // ignore: avoid-late-keyword
  String str;

  Parser(this.str);

  void nextChar() {
    ch = (++pos < str.length) ? str[pos] : '-1';
  }

  bool eat(String charToEat) {
    while (ch == ' ') {
      nextChar();
    }
    if (ch == charToEat.toString()) {
      nextChar();
      return true;
    }
    return false;
  }

  int? parse() {
    try {
      nextChar();
      int x = parseCondition()!; // ignore: avoid-non-null-assertion
      if (pos < str.length) {
        if (kDebugMode) {
          print("Unexpected: $ch");
        }
        return null;
        //throw Exception("Unexpected: $ch");
      }
      return x;
    } catch (_) {
      return null;
    }
  }

  // Grammar:
  // condition = expression | `>` expression | `<` expression | '=' expression
  // expression = term | expression `+` term | expression `-` term
  // term = factor | term `*` factor | term `/` factor
  // factor = `+` factor | `-` factor | `(` expression `)` | number
  //        | functionName `(` expression `)` | functionName factor
  //        | factor `^` factor

  int? parseCondition() {
    try {
      int x = parseExpression()!; // ignore: avoid-non-null-assertion
      for (;;) {
        if (eat('<')) {
          x = x < parseExpression()! ? 1 : 0; // ignore: avoid-non-null-assertion
        } else if (eat('>')) {
          x = x > parseExpression()! ? 1 : 0; // ignore: avoid-non-null-assertion
        } else if (eat('=')) {
          x = x == parseExpression()! ? 1 : 0; // ignore: avoid-non-null-assertion
        } else {
          return x;
        }
      }
    } catch (_) {
      return null;
    }
  }

  int? parseExpression() {
    try {
      int x = parseTerm()!; // ignore: avoid-non-null-assertion
      for (;;) {
        if (eat('+')) {
          x += parseTerm()!; // ignore: avoid-non-null-assertion
        } else if (eat('-')) {
          x -= parseTerm()!; // ignore: avoid-non-null-assertion
        } else {
          return x;
        }
      }
    } catch (_) {
      return null;
    }
  }

  int? parseTerm() {
    try {
      int x = parseFactor()!; // ignore: avoid-non-null-assertion
      for (;;) {
        if (eat('*')) x *= parseFactor()!; // multiplication // ignore: avoid-non-null-assertion
        if (eat('x')) {
          x *= parseFactor()!; // multiplication // ignore: avoid-non-null-assertion
        } else if (eat('/')) {
          x = (x / parseFactor()!).ceil(); // ignore: avoid-non-null-assertion
        } else if (eat('d')) {
          x = (x / parseFactor()!).floor(); // ignore: avoid-non-null-assertion
        } else {
          return x;
        }
      }
    } catch (_) {
      return null;
    }
  }

  int? parseFactor() {
    try {
      if (eat('+')) return parseFactor(); // unary plus
      if (eat('-')) return -parseFactor()!; // unary minus // ignore: avoid-non-null-assertion

      int x;
      int startPos = pos;
      int asciiValue = ch.codeUnits.first;
      if (eat('(')) {
        // parentheses
        x = parseExpression()!; // ignore: avoid-non-null-assertion
        if (!eat(')')) throw Exception("Missing ')'");
      } else if (asciiValue >= '0'.codeUnits.first &&
          asciiValue <= '9'.codeUnits.first) {
        // numbers
        while ((asciiValue >= '0'.codeUnits.first &&
            asciiValue <= '9'.codeUnits.first)) {
          nextChar();
          asciiValue = ch.codeUnits.first;
        }
        x = int.parse(str.substring(startPos, pos));
      } else {
        throw Exception("Unexpected: $ch");
      }
      return x;
    } catch (_) {
      return null;
    }
  }
}
