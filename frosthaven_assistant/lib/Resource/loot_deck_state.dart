import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';

import '../services/service_locator.dart';
import 'card_stack.dart';

enum LootType { materiel, other }

enum LootBaseValue { one, oneIf4twoIfNot, oneIf3or4twoIfNot }

class LootCard {
  String gfx;
  LootBaseValue baseValue;
  LootType lootType;
  bool enhanced;

  LootCard(
      {required this.lootType,
      required this.baseValue,
      required this.enhanced,
      required this.gfx});

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
    if (enhanced) {
      value++;
    }
    int characters = GameMethods.getCurrentCharacterAmount();
    if (characters >= 4) {
      return value;
    }
    if (baseValue == LootBaseValue.oneIf4twoIfNot) {
      value++;
    } else if (characters <= 2 &&
        baseValue == LootBaseValue.oneIf3or4twoIfNot) {
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

  //2 +1, 3 oneIf3or4twoIfNot, 3 oneIf4twoIfNot
  List<bool> metalEnhancements = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> hideEnhancements = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> lumberEnhancements = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  final CardStack<LootCard> drawPile = CardStack<LootCard>();
  final CardStack<LootCard> discardPile = CardStack<LootCard>();
  bool hasCard1418 = false;
  bool hasCard1419 = false;

  final cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?

  LootDeck(LootDeckModel model, LootDeck other) {
    hasCard1418 = other.hasCard1418;
    hasCard1419 = other.hasCard1419;
    lumberEnhancements = other.lumberEnhancements;
    metalEnhancements = other.metalEnhancements;
    hideEnhancements = other.hideEnhancements;
    //build deck
    _initPools();
    setDeck(model);
  }

  LootDeck.from(LootDeck other) {
    hasCard1418 = other.hasCard1418;
    hasCard1419 = other.hasCard1419;
    lumberEnhancements = other.lumberEnhancements;
    metalEnhancements = other.metalEnhancements;
    hideEnhancements = other.hideEnhancements;

    _initPools();
  }

  LootDeck.empty() {
    _initPools();
  }

  void setDeck(LootDeckModel model) {
    List<LootCard> cards = [];

    if (hasCard1419) {
      _addOtherType(cards, "special 1419");
    }
    if (hasCard1418) {
      _addOtherType(cards, "special 1418");
    }

    for (int i = 0; i < model.arrowvine; i++) {
      _addOtherType(cards, "arrowvine");
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
    cards.add(LootCard(
        baseValue: LootBaseValue.one,
        enhanced: false,
        lootType: LootType.other,
        gfx: gfx));
  }

  void _initMaterialPool(
      List<LootCard> list, String gfx, List<bool> enhancements) {
    list.clear();
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(
          baseValue: LootBaseValue.one,
          enhanced: enhancements[i],
          lootType: LootType.materiel,
          gfx: gfx));
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          baseValue: LootBaseValue.oneIf3or4twoIfNot,
          enhanced: enhancements[i + 2],
          lootType: LootType.materiel,
          gfx: gfx));
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          baseValue: LootBaseValue.oneIf4twoIfNot,
          enhanced: enhancements[i + 5],
          lootType: LootType.materiel,
          gfx: gfx));
    }
    list.shuffle();
  }

  void _initPools() {
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

    _initMaterialPool(lumberPool, "lumber", lumberEnhancements);
    _initMaterialPool(hidePool, "hide", hideEnhancements);
    _initMaterialPool(metalPool, "metal", metalEnhancements);
  }

  void addSpecial1418() {
    if (hasCard1418 != true) {
      hasCard1418 = true;
      drawPile.getList().add(LootCard(
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: false,
          gfx: "special 1418"));
      //add directly to current deck and shuffle. save state separately
      shuffle();
    }
  }

  void addSpecial1419() {
    if (hasCard1419 != true) {
      hasCard1419 = true;
      drawPile.getList().add(LootCard(
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: false,
          gfx: "special 1419"));
      shuffle();
    }
  }

  void removeSpecial1418() {
    hasCard1418 = false;
    drawPile.getList().removeWhere((element) => element.gfx == "special 1418");
    discardPile
        .getList()
        .removeWhere((element) => element.gfx == "special 1418");
  }

  void removeSpecial1419() {
    hasCard1419 = false;
    drawPile.getList().removeWhere((element) => element.gfx == "special 1419");
    discardPile
        .getList()
        .removeWhere((element) => element.gfx == "special 1419");
  }

  void flipEnhancement(bool value, int index, String identifier) {
    List enhancementList = lumberEnhancements;
    if (identifier == "metal") {
      enhancementList = metalEnhancements;
    }
    if (identifier == "hide") {
      enhancementList = hideEnhancements;
    }
    enhancementList[index] = value;

    //reset loot deck
    _initPools();
    GameState gameState = getIt<GameState>();
    String scenario = gameState.scenario.value;
    LootDeckModel? lootDeckModel = gameState.modelData
        .value[gameState.currentCampaign.value]!.scenarios[scenario]!.lootDeck;
    if (lootDeckModel != null) {
      setDeck(lootDeckModel);
    }
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
        '"metalEnhancements": ${metalEnhancements.toString()}, '
        '"lumberEnhancements": ${lumberEnhancements.toString()}, '
        '"hideEnhancements": ${hideEnhancements.toString()}, '
        '"1418": $hasCard1418, '
        '"1419": $hasCard1419 '
        '}';
  }
}
