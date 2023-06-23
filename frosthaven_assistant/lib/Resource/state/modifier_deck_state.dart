import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../card_stack.dart';

enum CardType { add, multiply, curse, bless, enfeeble }

class ModifierCard {
  CardType type;
  String gfx;

  ModifierCard(this.type, this.gfx);

  @override
  String toString() {
    return '{'
        '"gfx": "$gfx" '
        '}';
  }
}

class ModifierDeck {
  ModifierDeck(this.name) {
    //build deck
    initDeck(name);
    curses.removeListener(_curseListener);
    blesses.removeListener(_blessListener);
    enfeebles.removeListener(_enfeebleListener);

    curses.addListener(_curseListener);
    blesses.addListener(_blessListener);
    enfeebles.addListener(_enfeebleListener);
  }

  void _curseListener() {
    _handleCurseBless(CardType.curse, curses, "curse");
  }

  void _blessListener() {
    _handleCurseBless(CardType.bless, blesses, "bless");
  }

  void _enfeebleListener() {
    _handleCurseBless(CardType.enfeeble, enfeebles, "enfeeble");
  }

  void initDeck(String name) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    List<ModifierCard> cards = [];
    cards.add(ModifierCard(CardType.add, "minus2$suffix"));
    cards.add(ModifierCard(CardType.add, "plus2$suffix"));
    cards.add(ModifierCard(CardType.multiply, "doubleAttack$suffix"));
    cards.add(ModifierCard(CardType.multiply, "nullAttack$suffix"));
    for (int i = 0; i < 5; i++) {
      cards.add(ModifierCard(CardType.add, "minus1$suffix"));
      cards.add(ModifierCard(CardType.add, "plus1$suffix"));
    }
    for (int i = 0; i < 6; i++) {
      cards.add(ModifierCard(CardType.add, "plus0$suffix"));
    }
    drawPile.setList(cards);
    discardPile.setList([]);
    shuffle();
    cardCount.value = drawPile.size();
    curses.value = 0;
    blesses.value = 0;
    enfeebles.value = 0;
    badOmen.value = 0;
    addedMinusOnes.value = 0;
    needsShuffle = false;
    name = name;
  }

  final String name;
  bool needsShuffle = false;
  final CardStack<ModifierCard> drawPile = CardStack<ModifierCard>();
  final CardStack<ModifierCard> discardPile = CardStack<ModifierCard>();

  final curses = ValueNotifier<int>(0);
  final blesses = ValueNotifier<int>(0);
  final enfeebles = ValueNotifier<int>(0);
  final cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?

  final badOmen = ValueNotifier<int>(0);
  final addedMinusOnes = ValueNotifier<int>(0);

  void addMinusOne() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    addedMinusOnes.value++;
    drawPile.getList().add(ModifierCard(CardType.add, "minus1$suffix"));
    drawPile.shuffle();
    cardCount.value++;
  }

  void removeMinusOne() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    shuffle();
    addedMinusOnes.value--;
    var card = drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "minus1$suffix");
    if (card != null) {
      drawPile.getList().remove(card);
      drawPile.shuffle();
      cardCount.value--;
    }
  }

  bool hasMinus1() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus1$suffix") !=
            null ||
        discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus1$suffix") !=
            null;
  }

  bool hasMinus2() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus2$suffix") !=
            null ||
        discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus2$suffix") !=
            null;
  }

  bool hasNull() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "nullAttack$suffix") !=
            null ||
        discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "nullAttack$suffix") !=
            null;
  }

  void removeNull() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    shuffle();
    var card = drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "nullAttack$suffix");
    if (card != null) {
      drawPile.getList().remove(card);
      drawPile.shuffle();
      cardCount.value--;
    }
  }

  void addNull() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    drawPile
        .getList()
        .add(ModifierCard(CardType.multiply, "nullAttack$suffix"));
    shuffle();
  }

  void removeMinusTwo() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    shuffle();
    var card = drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "minus2$suffix");
    if (card != null) {
      drawPile.getList().remove(card);
      drawPile.shuffle();
      cardCount.value--;
    }
  }

  void addMinusTwo() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    drawPile.getList().add(ModifierCard(CardType.add, "minus2$suffix"));
    shuffle();
  }

  void _handleCurseBless(
      CardType type, ValueNotifier<int> notifier, String gfx) {
    //count and add or remove, then shuffle
    int count = 0;
    bool shuffle = true;
    for (var item in drawPile.getList()) {
      if (item.type == type) {
        count++;
      }
    }
    if (count == notifier.value) {
      shuffle = false;
    } else if (count < notifier.value) {
      for (int i = count; i < notifier.value; i++) {
        if (type == CardType.curse && badOmen.value > 0) {
          badOmen.value--;
          shuffle = false;
          //put in sixth or as far down as it goes.
          int position = 5;
          if (drawPile.getList().length < 6) {
            position = drawPile.getList().length;
          }
          drawPile.getList().insert(
              drawPile.getList().length - position, ModifierCard(type, gfx));
        } else {
          drawPile.push(ModifierCard(type, gfx));
        }
      }
    } else {
      int toRemove = count - notifier.value;
      for (int i = 0; i < toRemove; i++) {
        for (int j = drawPile.getList().length - 1; j >= 0; j--) {
          if (drawPile.getList()[j].type == type) {
            drawPile.getList().removeAt(j);
            break;
          }
        }
      }
    }
    if (shuffle) {
      drawPile.shuffle();
    }
    cardCount.value = drawPile.size();
  }

  void shuffle() {
    while (discardPile.isNotEmpty) {
      ModifierCard card = discardPile.pop();
      //remove curse and bless
      if (card.type != CardType.bless &&
          card.type != CardType.curse &&
          card.type != CardType.enfeeble) {
        drawPile.push(card);
      }
    }
    drawPile.shuffle();
    needsShuffle = false;
    cardCount.value = drawPile.size();
  }

  void draw() {
    //shuffle deck, for the case the deck ends during play
    if (drawPile.isEmpty) {
      shuffle();
    }
    //put top of draw pile on discard pile
    ModifierCard card = drawPile.pop();
    if (card.type == CardType.multiply) {
      needsShuffle = true;
    }

    if (card.type == CardType.curse) {
      curses.value--;
    }
    if (card.type == CardType.bless) {
      blesses.value--;
    }
    if (card.type == CardType.enfeeble) {
      enfeebles.value--;
    }

    discardPile.push(card);
    cardCount.value = drawPile.size();
  }

  @override
  String toString() {
    return '{'
        //'"cardCount": ${cardCount.value}, '
        '"blesses": ${blesses.value}, '
        '"curses": ${curses.value}, '
        '"enfeebles": ${enfeebles.value}, '
        // '"needsShuffle": ${needsShuffle}, '
        '"addedMinusOnes": ${addedMinusOnes.value.toString()}, '
        '"badOmen": ${badOmen.value.toString()}, '
        '"drawPile": ${drawPile.toString()}, '
        '"discardPile": ${discardPile.toString()} '
        '}';
  }
}
