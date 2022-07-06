import 'package:flutter/foundation.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class StatCalculator {
  static int? calculateFormula(final dynamic str) {
    if (str is int) {
      return str;
    }
    int C = GameMethods.getCurrentCharacters().length;
    if (C == 0) {
      C = 1;
    }
    int L = getIt<GameState>().level.value;
    String formula = str.replaceAll("C", C.toString());
    formula = formula.replaceAll("L", L.toString());
    return eval(formula);
  }

  static int? eval(final String str) {
    return Parser(str).parse();
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
      int x = parseExpression()!;
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
  // expression = term | expression `+` term | expression `-` term
  // term = factor | term `*` factor | term `/` factor
  // factor = `+` factor | `-` factor | `(` expression `)` | number
  //        | functionName `(` expression `)` | functionName factor
  //        | factor `^` factor

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
        if (eat('x'))
          x *= parseFactor()!; // multiplication
        else if (eat('/')) {
          x = (x / parseFactor()!).ceil();
        } else {
          return x;
        }
      }
    } catch(_) {
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
