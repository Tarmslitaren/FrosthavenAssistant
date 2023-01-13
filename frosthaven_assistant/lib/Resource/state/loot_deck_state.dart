
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/scenario.dart';
import 'package:frosthaven_assistant/Resource/enums.dart';
import 'package:frosthaven_assistant/Resource/game_methods.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';
import '../card_stack.dart';
import 'character.dart';

enum LootType { materiel, other }

enum LootBaseValue { one, oneIf4twoIfNot, oneIf3or4twoIfNot }

class LootCard {
  final String gfx;
  final int id;
  final LootBaseValue baseValue;
  final LootType lootType;
  int enhanced;
  late String owner;

  LootCard(
      {
        required this.id,
        required this.lootType,
        required this.baseValue,
        required this.enhanced,
        required this.gfx
      }) {
    owner = "";
  }

  @override
  String toString() {
    return '{'
        '"gfx": "$gfx", '
        '"owner": "$owner", '
        '"id": $id, '
        '"enhanced": $enhanced, '
        '"baseValue": ${baseValue.index}, '
        '"lootType": ${lootType.index} '
        '}';
  }

  int? getValue() {
    int value = 1;
    if (lootType == LootType.other) {
      if(enhanced > 0) {
        return enhanced;
      }
      return null;
    }
    if (enhanced > 0) {
      value+= enhanced;
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
  List<LootCard> corpsecapPool = [];
  List<LootCard> arrowvinePool = [];
  List<LootCard> flamefruitPool = [];
  List<LootCard> axenutPool = [];
  List<LootCard> rockrootPool = [];
  List<LootCard> snowthistlePool = [];


  //2 +1, 3 oneIf3or4twoIfNot, 3 oneIf4twoIfNot

  List<int> addedCards = [0,0,0,0,0,0,0,0,0];
  Map<int, int> enhancements = {};

  final CardStack<LootCard> drawPile = CardStack<LootCard>();
  final CardStack<LootCard> discardPile = CardStack<LootCard>();
  bool hasCard1418 = false;
  bool hasCard1419 = false;

  final cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?

  LootDeck(LootDeckModel model, LootDeck other) {
    hasCard1418 = other.hasCard1418;
    hasCard1419 = other.hasCard1419;
    addedCards = other.addedCards;
    enhancements = other.enhancements;

    //build deck
    _initPools();
    setDeck(model);
  }

  LootDeck.from(LootDeck other) {
    hasCard1418 = other.hasCard1418;
    hasCard1419 = other.hasCard1419;
    addedCards = other.addedCards;
    enhancements = other.enhancements;

    _initPools();
  }

  LootDeck.empty() {
    _initPools();
  }

  void _addCardFromPool(int amount, List<LootCard> pool, List<LootCard> cards) {
    pool.shuffle();
    if(amount > pool.length) {
      amount = pool.length;
    }
    for (int i = 0; i < amount; i++) {
      cards.add(pool[i]);
    }
    pool.sort((a,b) => a.id - b.id); //may not be needed
  }

  void setDeck(LootDeckModel model) {
    List<LootCard> cards = [];

    if (hasCard1419) {
      _addOtherType(1419, cards, "special 1419");
    }
    if (hasCard1418) {
      _addOtherType(1418, cards, "special 1418");
    }

    _addCardFromPool(model.arrowvine, arrowvinePool,cards);
    _addCardFromPool(model.corpsecap, corpsecapPool,cards);
    _addCardFromPool(model.axenut, axenutPool,cards);
    _addCardFromPool(model.flamefruit, flamefruitPool,cards);
    _addCardFromPool(model.rockroot, rockrootPool,cards);
    _addCardFromPool(model.snowthistle, snowthistlePool,cards);

    _addCardFromPool(model.coin, coinPool,cards);
    _addCardFromPool(model.metal, metalPool,cards);
    _addCardFromPool(model.hide, hidePool,cards);
    _addCardFromPool(model.lumber, lumberPool,cards);

    for (int i = 0; i < model.treasure; i++) {
      _addOtherType(9999, cards, "treasure");
    }

    drawPile.setList(cards);
    discardPile.setList([]);
    shuffle();
    cardCount.value = drawPile.size();
  }

  void _addOtherType(int id, List<LootCard> cards, String gfx) {
    cards.add(LootCard(
        id: id,
        baseValue: LootBaseValue.one,
        enhanced: enhancements[id] != null ? enhancements[id]!:0,
        lootType: LootType.other,
        gfx: gfx,
    ));
  }

  void _initMaterialPool(int startId,
      List<LootCard> list, String gfx) {
    list.clear();
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.one,
          enhanced: enhancements[startId] != null ? enhancements[startId]!:0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.oneIf3or4twoIfNot,
          enhanced: enhancements[startId] != null ? enhancements[startId]!:0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.oneIf4twoIfNot,
          enhanced: enhancements[startId] != null ? enhancements[startId]!:0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    //list.shuffle();
  }

  void _initHerbPool(int startId,
      List<LootCard> list, String gfx) {
    list.clear();
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.one,
          enhanced: enhancements[startId] != null ? enhancements[startId]!:0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    //list.shuffle();
  }

  void _initPools() {
    coinPool = [];
    lumberPool = [];
    hidePool = [];
    metalPool = [];
    axenutPool = [];
    arrowvinePool = [];
    rockrootPool = [];
    flamefruitPool = [];
    snowthistlePool = [];
    corpsecapPool = [];

    int id = 1;

    for (int i = 0; i < 12; i++) {
      _addOtherType(id, coinPool, "coin 1");
      id++;
    }
    for (int i = 0; i < 6; i++) {
      _addOtherType(id, coinPool, "coin 2");
      id++;
    }
    _addOtherType(id, coinPool, "coin 3");
    id++;
    _addOtherType(id, coinPool, "coin 3");
    id++;
    //coinPool.shuffle();

    _initMaterialPool(id, lumberPool, "lumber");
    id += 8;
    _initMaterialPool(id, hidePool, "hide");
    id += 8;
    _initMaterialPool(id, metalPool, "metal");
    id += 8;
    _initHerbPool(id, arrowvinePool, "arrowvine");
    id += 2;
    _initHerbPool(id, axenutPool, "axenut");
    id += 2;
    _initHerbPool(id, corpsecapPool, "corpsecap");
    id += 2;
    _initHerbPool(id, flamefruitPool, "flamefruit");
    id += 2;
    _initHerbPool(id, snowthistlePool, "snowthistle");
    id += 2;
    _initHerbPool(id, rockrootPool, "rockroot");

  }

  void addSpecial1418() {
    if (hasCard1418 != true) {
      hasCard1418 = true;
      drawPile.getList().add(LootCard(
          id:1418,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1418"));
      //add directly to current deck and shuffle. save state separately
      shuffle();
    }
  }

  void addSpecial1419() {
    if (hasCard1419 != true) {
      hasCard1419 = true;
      drawPile.getList().add(LootCard(
          id: 1419,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1419"));
      shuffle();
    }
  }

  void removeSpecial1418() {
    hasCard1418 = false;
    drawPile.getList().removeWhere((element) => element.id == 1418);
    discardPile
        .getList()
        .removeWhere((element) => element.id == 1418);
    cardCount.value = drawPile.size();
  }

  void removeSpecial1419() {
    hasCard1419 = false;
    drawPile.getList().removeWhere((element) => element.id == 1419);
    discardPile
        .getList()
        .removeWhere((element) => element.id == 1419);
    cardCount.value = drawPile.size();
  }

  List<LootCard> _getAvailableCards(List<LootCard> pool) {
    List<LootCard> list = [];
    for (var item in pool) {
      if(!drawPile.getList().any((element) => element.id == item.id)) {
        list.add(item);
      }
    }
    list.shuffle();
    return list;
  }

  void addExtraCard(String identifier) {
    _initPools();
    shuffle();
    if (identifier == "hide") {
      drawPile.getList().add(_getAvailableCards(hidePool)[addedCards[0]]);
      addedCards[0]++;
    }
    if (identifier == "lumber") {
      drawPile.getList().add(_getAvailableCards(lumberPool)[addedCards[1]]);
      addedCards[1]++;
    }
    if (identifier == "metal") {
      drawPile.getList().add(_getAvailableCards(metalPool)[addedCards[2]]);
      addedCards[2]++;
    }
    if (identifier == "arrowvine") {
      drawPile.getList().add(_getAvailableCards(arrowvinePool)[addedCards[3]]);
      addedCards[3]++;
    }
    if (identifier == "axenut") {
      drawPile.getList().add(_getAvailableCards(axenutPool)[addedCards[4]]);
      addedCards[4]++;
    }
    if (identifier == "corpsecap") {
      drawPile.getList().add(_getAvailableCards(corpsecapPool)[addedCards[5]]);
      addedCards[5]++;
    }
    if (identifier == "flamefruit") {
      drawPile.getList().add(_getAvailableCards(flamefruitPool)[addedCards[6]]);
      addedCards[6]++;
    }
    if (identifier == "rockroot") {
      drawPile.getList().add(_getAvailableCards(rockrootPool)[addedCards[7]]);
      addedCards[7]++;
    }
    if (identifier == "snowthistle") {
      drawPile.getList().add(_getAvailableCards(snowthistlePool)[addedCards[8]]);
      addedCards[8]++;
    }
    shuffle();
  }

  void addEnhancement(int id, int value, String identifier) {
    enhancements[id] = value;
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

    //mark owner
    for(var item in getIt<GameState>().currentList){
      if(item.turnState == TurnsState.current && item is Character) {
        card.owner = item.characterClass.name;
      }
    }

    discardPile.push(card);
    cardCount.value = drawPile.size();
  }

  @override
  String toString() {
    return '{'
        '"drawPile": ${drawPile.toString()}, '
        '"discardPile": ${discardPile.toString()}, '
        '"addedCards": ${addedCards.toString()}, '
        '"enhancements": ${enhancements.toString()}, '
        '"1418": $hasCard1418, '
        '"1419": $hasCard1419 '
        '}';
  }
}
