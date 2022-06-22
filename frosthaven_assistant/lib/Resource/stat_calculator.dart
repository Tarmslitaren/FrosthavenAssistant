
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class StatCalculator {
  static int getHitPoints(final dynamic str) {
    if(str is int) {
      return str;
    }
    int C = GameMethods.getCurrentCharacters().length;
    int L = getIt<GameState>().level.value;
    String formula = str.replaceAll("C", C.toString());
    formula = formula.replaceAll("L", L.toString());
    return eval(formula);
  }

  static int eval(final String str) {
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

  int parse() {
    nextChar();
    int x = parseExpression();
    if (pos < str.length) {
      throw Exception("Unexpected: $ch");
    }
    return x;
  }

  // Grammar:
  // expression = term | expression `+` term | expression `-` term
  // term = factor | term `*` factor | term `/` factor
  // factor = `+` factor | `-` factor | `(` expression `)` | number
  //        | functionName `(` expression `)` | functionName factor
  //        | factor `^` factor

  int parseExpression() {
    int x = parseTerm();
    for (;;) {
      if (eat('+')) {
        x += parseTerm();
      } else if (eat('-')) {
        x -= parseTerm();
      } else {
        return x;
      }
    }
  }

  int parseTerm() {
    int x = parseFactor();
    for (;;) {
      if (eat('*')) x *= parseFactor(); // multiplication
      if (eat('x')) x *= parseFactor(); // multiplication
      else if (eat('/')) {
        x = x ~/ parseFactor();
      } else {
        return x;
      }
    }
  }

  int parseFactor() {
    if (eat('+')) return parseFactor(); // unary plus
    if (eat('-')) return -parseFactor(); // unary minus

    int x;
    int startPos = pos;
    int asciiValue = ch.codeUnits[0];
    if (eat('(')) { // parentheses
      x = parseExpression();
      if (!eat(')')) throw Exception("Missing ')'");
    } else if (asciiValue >= '0'.codeUnits[0] &&
        asciiValue <= '9'.codeUnits[0]) { // numbers
      while ((asciiValue >= '0'.codeUnits[0] &&
          asciiValue <= '9'.codeUnits[0])) {
        nextChar();
        asciiValue = ch.codeUnits[0];
      }
      x = int.parse(str.substring(startPos, pos));
    }
    // else if (asciiValue >= 'a' && asciiValue <= 'z') { // functions
    /*while (asciiValue >= 'a' && asciiValue <= 'z') {
        nextChar();
        asciiValue = ch.codeUnits[0];
      }*/

    //don't need functions
    /*String func = str.substring(startPos, pos);
      if (eat('(')) {
        x = parseExpression();
        if (!eat(')')) {
          throw Exception(
            "Missing ')' after argument to $func");
        }
      } else {
        x = parseFactor();
      }
      if (func == "sqrt") x = sqrt(x);
      else if (func =="sin") x = sin(toRadians(x));
          else if (func == "cos") x = cos(toRadians(x));
          else if (func == "tan") x = tan(toRadians(x));
      else {
        throw Exception("Unknown function: $func");
      }*/
    // }
    else {
      throw Exception("Unexpected: $ch");
    }
    //if (eat('^')) x = pow(x, parseFactor()); // exponentiation
    return x;
  }
}

