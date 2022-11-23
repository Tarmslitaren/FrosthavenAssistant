
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';

import 'card_stack.dart';

enum LootType {
  materiel,
  other
}

enum BaseValue {
  one,
  oneIf4twoIfNot,
  oneIf3or4twoIfNot
}

class LootCard {
  String gfx;
  BaseValue baseValue;
  LootType lootType;
  bool enhanced;

  LootCard({required this.lootType, required this.baseValue, required this.enhanced, required this.gfx});

  @override
  String toString() {
    return '{'
        '"gfx": "$gfx", '
        '"enhanced": $enhanced, '
        '"baseValue": ${baseValue.index}, '
        '"lootType": ${lootType.index} '
        '}';
  }

  int? getValue() {
    int value = 1;
    if (lootType == LootType.other) {
      return null;
    }
    if(enhanced) {
      value++;
    }
    int characters = GameMethods.getCurrentCharacterAmount();
    if(characters >= 4) {
      return value;
    }
    if (baseValue == BaseValue.oneIf4twoIfNot) {
      value++;
    } else if (characters <= 2 && baseValue == BaseValue.oneIf3or4twoIfNot) {
      value++;
    }
    return value;
  }
}

class LootDeck {
  List<LootCard> coinPool = [];
  List<LootCard> lumberPool = [];
  List<LootCard> hidePool = [];
  List<LootCard> metalPool = [];

  final CardStack<LootCard> drawPile = CardStack<LootCard>();
  final CardStack<LootCard> discardPile = CardStack<LootCard>();
  bool hasCard1418 = false;
  bool hasCard1419 = false;//todo: remember to save state should these be outside this class?

  final cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?


  LootDeck(LootDeckModel model, this.hasCard1418, this.hasCard1419) {
    //build deck
    _initPools();
    setDeck(model);
  }

  LootDeck.empty(this.hasCard1418, this.hasCard1419) {
    //build deck
    _initPools();
  }

  void setDeck(LootDeckModel model) {
    List<LootCard> cards = [];

    if(hasCard1419) {
      _addOtherType(cards, "special 1419");
    }
    if(hasCard1418) {
      _addOtherType(cards, "special 1418");
    }

    for (int i = 0; i < model.arrowvine; i++) {
      _addOtherType(cards, "arrowVine");
    }
    for (int i = 0; i < model.corpsecap; i++) {
      _addOtherType(cards, "corpsecap");
    }
    for (int i = 0; i < model.axenut; i++) {
      _addOtherType(cards, "axenut");
    }
    for (int i = 0; i < model.flamefruit; i++) {
      _addOtherType(cards, "flamefruit");
    }
    for (int i = 0; i < model.rockroot; i++) {
      _addOtherType(cards, "rockroot");
    }
    for (int i = 0; i < model.snowthistle; i++) {
      _addOtherType(cards, "snowthistle");
    }
    for (int i = 0; i < model.treasure; i++) {
      _addOtherType(cards, "treasure");
    }

    for (int i = 0; i < model.coin; i++) {
      cards.add(coinPool[i]);
    }
    for (int i = 0; i < model.metal; i++) {
      cards.add(metalPool[i]);
    }
    for (int i = 0; i < model.hide; i++) {
      cards.add(hidePool[i]);
    }
    for (int i = 0; i < model.lumber; i++) {
      cards.add(lumberPool[i]);
    }

    drawPile.setList(cards);
    discardPile.setList([]);
    shuffle();
    cardCount.value = drawPile.size();
  }

  void _addOtherType(List<LootCard> cards, String gfx) {
    cards.add(LootCard(baseValue: BaseValue.one, enhanced: false, lootType: LootType.other, gfx: gfx));
  }

  void _initMaterialPool(List<LootCard> list, String gfx) {
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(baseValue: BaseValue.one, enhanced: false, lootType: LootType.materiel, gfx: gfx));
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(baseValue: BaseValue.oneIf3or4twoIfNot, enhanced: false, lootType: LootType.materiel, gfx: gfx));
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(baseValue: BaseValue.oneIf4twoIfNot, enhanced: false, lootType: LootType.materiel, gfx: gfx));
    }
    list.shuffle();
  }

  void _initPools() {
    //TODO: handle enhnacements
    coinPool = [];
    lumberPool = [];
    hidePool = [];
    metalPool = [];

    for (int i = 0; i < 12; i++) {
      _addOtherType(coinPool, "coin 1");
    }
    for (int i = 0; i < 6; i++) {
      _addOtherType(coinPool, "coin 2");
    }
    _addOtherType(coinPool, "coin 3");
    _addOtherType(coinPool, "coin 3");

    _initMaterialPool(lumberPool, "lumber");
    _initMaterialPool(hidePool, "hide");
    _initMaterialPool(metalPool, "metal");
  }

  void addSpecial1418() {
    if(hasCard1418 != true) {
      hasCard1418 = true;
      drawPile.getList().add(LootCard(lootType: LootType.other, baseValue: BaseValue.one, enhanced: false, gfx: "special 1418"));
      //add directly to current deck and shuffle. save state separately
      shuffle();
    }
  }
  void addSpecial1419() {
    if(hasCard1419 != true) {
      hasCard1419 = true;
      drawPile.getList().add(LootCard(lootType: LootType.other, baseValue: BaseValue.one, enhanced: false, gfx: "special 1419"));
      shuffle();
    }
  }
  void removeSpecial1418(){
    hasCard1418 = false;
    drawPile.getList().removeWhere((element) => element.gfx == "special 1418");
  }
  void removeSpecial1419(){
    hasCard1419 = false;
    drawPile.getList().removeWhere((element) => element.gfx == "special 1419");
  }

  void shuffle() {
    while (discardPile.isNotEmpty) {
      LootCard card = discardPile.pop();
      drawPile.push(card);
    }
    drawPile.shuffle();
    cardCount.value = drawPile.size();
  }

  void draw() {
    //put top of draw pile on discard pile
    LootCard card = drawPile.pop();
    discardPile.push(card);
    cardCount.value = drawPile.size();
  }

  @override
  String toString() {
    return '{'
        '"drawPile": ${drawPile.toString()}, '
        '"discardPile": ${discardPile.toString()}, '
        '"1418": $hasCard1418, '
        '"1419": $hasCard1419 '
        '}';
  }
}
