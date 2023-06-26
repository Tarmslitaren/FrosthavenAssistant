import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class StatCalculator {
  static int? calculateFormula(final dynamic str) {
    if (str is int) {
      return str;
    }
    int C = GameMethods.getCurrentCharacterAmount();
    if (C < 2) {
      C = 2;
    }
    int L = getIt<GameState>().level.value;
    String formula = str.replaceAll("C", C.toString());
    formula = formula.replaceAll("L", L.toString());
    return eval(formula);
  }

  static int? eval(final String str) {
    return Parser(str).parse();
  }

  static bool evaluateCondition(final dynamic str) {
    return calculateFormula(str) == 1;
  }
}

class Parser {
  int pos = -1;
  late String ch;
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
      int x = parseCondition()!;
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
      int x = parseExpression()!;
      for (;;) {
        if (eat('<')) {
          x = x < parseExpression()! ? 1 : 0;
        } else if (eat('>')) {
          x = x > parseExpression()! ? 1 : 0;
        } else if (eat('=')) {
          x = x == parseExpression()! ? 1 : 0;
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
      int x = parseTerm()!;
      for (;;) {
        if (eat('+')) {
          x += parseTerm()!;
        } else if (eat('-')) {
          x -= parseTerm()!;
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
      int x = parseFactor()!;
      for (;;) {
        if (eat('*')) x *= parseFactor()!; // multiplication
        if (eat('x')) {
          x *= parseFactor()!; // multiplication
        } else if (eat('/')) {
          x = (x / parseFactor()!).ceil();
        } else if (eat('d')) {
          x = (x / parseFactor()!).floor();
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
      if (eat('-')) return -parseFactor()!; // unary minus

      int x;
      int startPos = pos;
      int asciiValue = ch.codeUnits[0];
      if (eat('(')) {
        // parentheses
        x = parseExpression()!;
        if (!eat(')')) throw Exception("Missing ')'");
      } else if (asciiValue >= '0'.codeUnits[0] &&
          asciiValue <= '9'.codeUnits[0]) {
        // numbers
        while ((asciiValue >= '0'.codeUnits[0] &&
            asciiValue <= '9'.codeUnits[0])) {
          nextChar();
          asciiValue = ch.codeUnits[0];
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
