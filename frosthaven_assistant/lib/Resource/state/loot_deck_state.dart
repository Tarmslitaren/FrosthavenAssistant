part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

enum LootType { materiel, other }

enum LootBaseValue { one, oneIf4twoIfNot, oneIf3or4twoIfNot }

class LootCard {
  final String gfx;
  final int id;
  final LootBaseValue baseValue;
  final LootType lootType;
  int get enhanced => _enhanced;
  late int _enhanced;
  late String owner;

  LootCard(
      {required this.id,
      required this.lootType,
      required this.baseValue,
      required enhanced,
      required this.gfx}) {
    _enhanced = enhanced;
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
      if (enhanced > 0) {
        return enhanced;
      }
      return null;
    }
    if (enhanced > 0) {
      value += enhanced;
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

  List<LootCard> _coinPool = [];
  List<LootCard> _lumberPool = [];
  List<LootCard> _hidePool = [];
  List<LootCard> _metalPool = [];
  List<LootCard> _corpsecapPool = [];
  List<LootCard> _arrowvinePool = [];
  List<LootCard> _flamefruitPool = [];
  List<LootCard> _axenutPool = [];
  List<LootCard> _rockrootPool = [];
  List<LootCard> _snowthistlePool = [];

  BuiltList<LootCard> get coinPool => BuiltList.of(_coinPool);
  BuiltList<LootCard> get lumberPool => BuiltList.of(_lumberPool);
  BuiltList<LootCard> get hidePool => BuiltList.of(_hidePool);
  BuiltList<LootCard> get metalPool => BuiltList.of(_metalPool);
  BuiltList<LootCard> get corpsecapPool => BuiltList.of(_corpsecapPool);
  BuiltList<LootCard> get arrowvinePool => BuiltList.of(_arrowvinePool);
  BuiltList<LootCard> get flamefruitPool => BuiltList.of(_flamefruitPool);
  BuiltList<LootCard> get axenutPool => BuiltList.of(_axenutPool);
  BuiltList<LootCard> get rockrootPool => BuiltList.of(_rockrootPool);
  BuiltList<LootCard> get snowthistlePool => BuiltList.of(_snowthistlePool);

  //2 +1, 3 oneIf3or4twoIfNot, 3 oneIf4twoIfNot

  BuiltList<int> get addedCards => BuiltList.of(_addedCards);
  List<int> _addedCards = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  Map<String, int> _enhancements = {};

  CardStack<LootCard> get drawPile => _drawPile;
  CardStack<LootCard> get discardPile => _discardPile;
  final CardStack<LootCard> _drawPile = CardStack<LootCard>();
  final CardStack<LootCard> _discardPile = CardStack<LootCard>();

  bool get hasCard1418 => _hasCard1418;
  bool _hasCard1418 = false;
  bool get hasCard1419 => _hasCard1419;
  bool _hasCard1419 = false;

  ValueListenable<int> get cardCount => _cardCount;
  final _cardCount = ValueNotifier<int>(0);
  //TODO: everything is a hammer - use maybe change notifier instead?

  LootDeck(LootDeckModel model, LootDeck other) {
    _hasCard1418 = other._hasCard1418;
    _hasCard1419 = other._hasCard1419;
    _enhancements = other._enhancements;

    //build deck
    _initPools();
    _setDeck(model);
  }

  LootDeck.from(LootDeck other) {
    _hasCard1418 = other._hasCard1418;
    _hasCard1419 = other._hasCard1419;
    _enhancements = other._enhancements;

    _initPools();
  }

  LootDeck.empty() {
    _initPools();
  }

  LootDeck.fromJson(dynamic lootDeckData) {
    _hasCard1418 = lootDeckData["1418"];
    _hasCard1419 = lootDeckData["1419"];

    if (lootDeckData.containsKey('addedCards')) {
      _addedCards = List<int>.from(lootDeckData['addedCards']);
    } else {
      _addedCards = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    }

    if (lootDeckData.containsKey('enhancements')) {
      _enhancements = Map<String, int>.from(lootDeckData['enhancements']);
    } else {
      _enhancements = {};
    }

    _initPools();

    List<LootCard> newDrawList = [];
    List drawPile = lootDeckData["drawPile"] as List;
    int id = 0;
    for (var item in drawPile) {
      String owner = "";
      String gfx = item["gfx"];
      if (item.containsKey('owner')) {
        owner = item["owner"];
      }
      if (item.containsKey('id')) {
        id = item["id"];
      }
      int enhanced = 0;
      if (item['enhanced'].runtimeType == bool) {
        bool enh = item['enhanced'];
        if (enh) {
          enhanced = 1;
        }
      } else {
        enhanced = item["enhanced"];
      }
      LootBaseValue baseValue = LootBaseValue.values[item["baseValue"]];
      LootType lootType = LootType.values[item["lootType"]];
      LootCard lootCard = LootCard(
          id: id,
          gfx: gfx,
          enhanced: enhanced,
          baseValue: baseValue,
          lootType: lootType);
      lootCard.owner = owner;
      newDrawList.add(lootCard);
    }
    List<LootCard> newDiscardList = [];
    for (var item in lootDeckData["discardPile"] as List) {
      String gfx = item["gfx"];
      String owner = "";
      if (item.containsKey('owner')) {
        owner = item["owner"];
      }
      if (item.containsKey('id')) {
        id = item["id"];
      }

      int enhanced = 0;
      if (item['enhanced'].runtimeType == bool) {
        bool enh = item['enhanced'];
        if (enh) {
          enhanced = 1;
        }
      } else {
        enhanced = item["enhanced"];
      }
      LootBaseValue baseValue = LootBaseValue.values[item["baseValue"]];
      LootType lootType = LootType.values[item["lootType"]];
      LootCard lootCard = LootCard(
          id: id,
          gfx: gfx,
          enhanced: enhanced,
          baseValue: baseValue,
          lootType: lootType);
      lootCard.owner = owner;
      newDiscardList.add(lootCard);
    }
    _drawPile.clear();
    _discardPile.clear();
    _drawPile.setList(newDrawList);
    _discardPile.setList(newDiscardList);
    _cardCount.value = _drawPile.size();
  }

  void _addCardFromPool(int amount, List<LootCard> pool, List<LootCard> cards) {
    pool.shuffle();
    if (amount > pool.length) {
      amount = pool.length;
    }
    for (int i = 0; i < amount; i++) {
      cards.add(pool[i]);
    }
    pool.sort((a, b) => a.id - b.id); //may not be needed
  }

  void setDeck(_StateModifier _, LootDeckModel model) {
    _setDeck(model);
  }

  void _setDeck(LootDeckModel model) {
    List<LootCard> cards = [];

    if (_hasCard1419) {
      _addOtherType(1419, cards, "special 1419");
    }
    if (_hasCard1418) {
      _addOtherType(1418, cards, "special 1418");
    }

    _addCardFromPool(model.arrowvine, _arrowvinePool, cards);
    _addCardFromPool(model.corpsecap, _corpsecapPool, cards);
    _addCardFromPool(model.axenut, _axenutPool, cards);
    _addCardFromPool(model.flamefruit, _flamefruitPool, cards);
    _addCardFromPool(model.rockroot, _rockrootPool, cards);
    _addCardFromPool(model.snowthistle, _snowthistlePool, cards);

    _addCardFromPool(model.coin, _coinPool, cards);
    _addCardFromPool(model.metal, _metalPool, cards);
    _addCardFromPool(model.hide, _hidePool, cards);
    _addCardFromPool(model.lumber, _lumberPool, cards);

    for (int i = 0; i < model.treasure; i++) {
      _addOtherType(9999, cards, "treasure");
    }

    _drawPile.setList(cards);
    _discardPile.setList([]);
    _shuffle();
    _cardCount.value = _drawPile.size();
  }

  void _addOtherType(int id, List<LootCard> cards, String gfx) {
    cards.add(LootCard(
      id: id,
      baseValue: LootBaseValue.one,
      enhanced: _enhancements[id.toString()] != null
          ? _enhancements[id.toString()]!
          : 0,
      lootType: LootType.other,
      gfx: gfx,
    ));
  }

  void _initMaterialPool(int startId, List<LootCard> list, String gfx) {
    list.clear();
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.one,
          enhanced: _enhancements[startId.toString()] != null
              ? _enhancements[startId.toString()]!
              : 0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.oneIf3or4twoIfNot,
          enhanced: _enhancements[startId.toString()] != null
              ? _enhancements[startId.toString()]!
              : 0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
    for (int i = 0; i < 3; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.oneIf4twoIfNot,
          enhanced: _enhancements[startId.toString()] != null
              ? _enhancements[startId.toString()]!
              : 0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
  }

  void _initHerbPool(int startId, List<LootCard> list, String gfx) {
    list.clear();
    for (int i = 0; i < 2; i++) {
      list.add(LootCard(
          id: startId,
          baseValue: LootBaseValue.one,
          enhanced: _enhancements[startId.toString()] != null
              ? _enhancements[startId.toString()]!
              : 0,
          lootType: LootType.materiel,
          gfx: gfx));
      startId++;
    }
  }

  void _initPools() {
    _coinPool = [];
    _lumberPool = [];
    _hidePool = [];
    _metalPool = [];
    _axenutPool = [];
    _arrowvinePool = [];
    _rockrootPool = [];
    _flamefruitPool = [];
    _snowthistlePool = [];
    _corpsecapPool = [];

    int id = 1;

    for (int i = 0; i < 12; i++) {
      _addOtherType(id, _coinPool, "coin 1");
      id++;
    }
    for (int i = 0; i < 6; i++) {
      _addOtherType(id, _coinPool, "coin 2");
      id++;
    }
    _addOtherType(id, _coinPool, "coin 3");
    id++;
    _addOtherType(id, _coinPool, "coin 3");
    id++;

    _initMaterialPool(id, _lumberPool, "lumber");
    id += 8;
    _initMaterialPool(id, _hidePool, "hide");
    id += 8;
    _initMaterialPool(id, _metalPool, "metal");
    id += 8;
    _initHerbPool(id, _arrowvinePool, "arrowvine");
    id += 2;
    _initHerbPool(id, _axenutPool, "axenut");
    id += 2;
    _initHerbPool(id, _corpsecapPool, "corpsecap");
    id += 2;
    _initHerbPool(id, _flamefruitPool, "flamefruit");
    id += 2;
    _initHerbPool(id, _snowthistlePool, "snowthistle");
    id += 2;
    _initHerbPool(id, _rockrootPool, "rockroot");
  }

  void addSpecial1418(_StateModifier _) {
    if (_hasCard1418 != true) {
      _hasCard1418 = true;
      _drawPile.add(LootCard(
          id: 1418,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1418"));
      //add directly to current deck and shuffle. save state separately
      _shuffle();
    }
  }

  void addSpecial1419(_StateModifier _) {
    if (_hasCard1419 != true) {
      _hasCard1419 = true;
      _drawPile.add(LootCard(
          id: 1419,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1419"));
      _shuffle();
    }
  }

  void removeSpecial1418(_StateModifier _) {
    _hasCard1418 = false;
    _drawPile.removeWhere((element) => element.id == 1418);
    _discardPile.removeWhere((element) => element.id == 1418);
    _cardCount.value = _drawPile.size();
  }

  void removeSpecial1419(_StateModifier _) {
    _hasCard1419 = false;
    _drawPile.removeWhere((element) => element.id == 1419);
    _discardPile.removeWhere((element) => element.id == 1419);
    _cardCount.value = _drawPile.size();
  }

  List<LootCard> _getAvailableCards(List<LootCard> pool) {
    List<LootCard> list = [];
    for (var item in pool) {
      if (!_drawPile.getList().any((element) => element.id == item.id)) {
        list.add(item);
      }
    }
    list.shuffle();
    return list;
  }

  void addExtraCard(_StateModifier _, String identifier) {
    _initPools();
    _shuffle();
    if (identifier == "hide") {
      var pool = _getAvailableCards(_hidePool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[0]++;
      }
    }
    if (identifier == "lumber") {
      var pool = _getAvailableCards(_lumberPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[1]++;
      }
    }
    if (identifier == "metal") {
      var pool = _getAvailableCards(_metalPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[2]++;
      }
    }
    if (identifier == "arrowvine") {
      var pool = _getAvailableCards(_arrowvinePool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[3]++;
      }
    }
    if (identifier == "axenut") {
      var pool = _getAvailableCards(_axenutPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[4]++;
      }
    }
    if (identifier == "corpsecap") {
      var pool = _getAvailableCards(_corpsecapPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[5]++;
      }
    }
    if (identifier == "flamefruit") {
      var pool = _getAvailableCards(_flamefruitPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[6]++;
      }
    }
    if (identifier == "rockroot") {
      var pool = _getAvailableCards(_rockrootPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[7]++;
      }
    }
    if (identifier == "snowthistle") {
      var pool = _getAvailableCards(_snowthistlePool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool[0]);
        _addedCards[8]++;
      }
    }
    _shuffle();
  }

  void addEnhancement(_StateModifier _, int id, int value, String identifier) {
    _enhancements[id.toString()] = value;
    //reset loot deck
    _initPools();
    GameState gameState = getIt<GameState>();
    GameData gameData = getIt<GameData>();
    String scenario = gameState.scenario.value;
    LootDeckModel? lootDeckModel = gameData.modelData
        .value[gameState.currentCampaign.value]!.scenarios[scenario]!.lootDeck;
    if (lootDeckModel != null) {
      _setDeck(lootDeckModel);
    }
  }


  void _shuffle() {
    while (_discardPile.isNotEmpty) {
      LootCard card = _discardPile.pop();
      _drawPile.push(card);
    }
    _drawPile.shuffle();
    _cardCount.value = _drawPile.size();
  }

  void draw(_StateModifier _) {
    //put top of draw pile on discard pile
    LootCard card = _drawPile.pop();

    //mark owner
    for (var item in getIt<GameState>().currentList) {
      if (item.turnState == TurnsState.current && item is Character) {
        if (!GameMethods.isObjectiveOrEscort(item.characterClass)) {
          card.owner = item.characterClass.id;
          break;
        }
      }
    }

    _discardPile.push(card);
    _cardCount.value = _drawPile.size();
  }

  @override
  String toString() {
    return '{'
        '"drawPile": ${_drawPile.toString()}, '
        '"discardPile": ${_discardPile.toString()}, '
        '"addedCards": ${_addedCards.toString()}, '
        '"enhancements": ${json.encode(_enhancements)}, '
        '"1418": $_hasCard1418, '
        '"1419": $_hasCard1419 '
        '}';
  }
}
