part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class LootCard { // ignore: prefer-match-file-name, file contains multiple loot deck state types
  static const int _kHighCharCount = 4;
  static const int _kLowCharCount = 2;

  final String gfx;
  final int id;
  final LootBaseValue baseValue;
  final LootType lootType;
  String owner = "";
  int _enhanced = 0;
  int get enhanced => _enhanced;

  LootCard(
      {required this.id,
      required this.lootType,
      required this.baseValue,
      required enhanced,
      required this.gfx}) {
    _enhanced = enhanced;
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
    if (characters >= _kHighCharCount) {
      return value;
    }
    if (baseValue == LootBaseValue.oneIf4twoIfNot) {
      value++;
    } else if (characters <= _kLowCharCount &&
        baseValue == LootBaseValue.oneIf3or4twoIfNot) {
      value++;
    }
    return value;
  }
}

class LootDeck {
  static const int _kSpecialCard1418 = 1418;
  static const int _kSpecialCard1419 = 1419;
  static const int _kTreasureCardId = 9999;
  static const int _kMaterialOneCount = 2;
  static const int _kMaterialTwoCount = 3;
  static const int _kHerbPoolCount = 2;
  static const int _kCoin1Count = 12;
  static const int _kCoin2Count = 6;
  static const int _kMaterialPoolSize = 8;
  static const int _kHerbPoolSize = 2;

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

  final CardStack<LootCard> _drawPile = CardStack<LootCard>();
  final CardStack<LootCard> _discardPile = CardStack<LootCard>();

  bool get drawPileIsEmpty => _drawPile.isEmpty;
  bool get drawPileIsNotEmpty => _drawPile.isNotEmpty;
  bool get discardPileIsEmpty => _discardPile.isEmpty;
  bool get discardPileIsNotEmpty => _discardPile.isNotEmpty;
  LootCard get drawPileTop => _drawPile.peek;
  LootCard get discardPileTop => _discardPile.peek;
  BuiltList<LootCard> get drawPileContents => BuiltList.of(_drawPile.getList());
  BuiltList<LootCard> get discardPileContents =>
      BuiltList.of(_discardPile.getList());
  int get drawPileSize => _drawPile.size();
  int get discardPileSize => _discardPile.size();

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

  LootDeck.fromJson(Map<String, dynamic> lootDeckData) {
    updateFromJson(lootDeckData);
  }

  /// Updates this deck in-place from [lootDeckData], firing [_cardCount] so
  /// subscribed widgets rebuild automatically.
  void updateFromJson(Map<String, dynamic> lootDeckData) {
    _hasCard1418 = lootDeckData["1418"] as bool;
    _hasCard1419 = lootDeckData["1419"] as bool;

    _addedCards = lootDeckData.containsKey('addedCards')
        ? List<int>.from(lootDeckData['addedCards'] as List)
        : [0, 0, 0, 0, 0, 0, 0, 0, 0];

    _enhancements = lootDeckData.containsKey('enhancements')
        ? Map<String, int>.from(lootDeckData['enhancements'] as Map)
        : {};

    _initPools();

    LootCard cardFromJson(Map<dynamic, dynamic> item, int fallbackId) {
      final String gfx = item["gfx"] as String;
      final String owner =
          item.containsKey('owner') ? item["owner"] as String : "";
      final int id = item.containsKey('id') ? item["id"] as int : fallbackId;

      // 'enhanced' was stored as bool in older saves, int in newer ones.
      int enhanced = 0;
      if (item['enhanced'] is bool) {
        enhanced = (item['enhanced'] as bool) ? 1 : 0;
      } else if (item['enhanced'] is num) {
        enhanced = (item['enhanced'] as num).toInt();
      }

      final baseIdx = item["baseValue"] is int ? item["baseValue"] as int : 0;
      final lootTypeIdx = item["lootType"] is int ? item["lootType"] as int : 0;
      final LootBaseValue baseValue =
          (baseIdx >= 0 && baseIdx < LootBaseValue.values.length)
              ? LootBaseValue.values[baseIdx]
              : LootBaseValue.values.first;
      final LootType lootType =
          (lootTypeIdx >= 0 && lootTypeIdx < LootType.values.length)
              ? LootType.values[lootTypeIdx]
              : LootType.values.first;

      return LootCard(
          id: id,
          gfx: gfx,
          enhanced: enhanced,
          baseValue: baseValue,
          lootType: lootType)
        ..owner = owner;
    }

    List<LootCard> newDrawList = [];
    List drawPile = lootDeckData["drawPile"] as List;
    int id = 0;
    for (var item in drawPile) {
      if (item.containsKey('id')) id = item["id"] as int;
      newDrawList.add(cardFromJson(item as Map, id));
    }
    List<LootCard> newDiscardList = [];
    for (var item in lootDeckData["discardPile"] as List) {
      if (item.containsKey('id')) id = item["id"] as int;
      newDiscardList.add(cardFromJson(item as Map, id));
    }
    _drawPile.clear();
    _discardPile.clear();
    _drawPile.setList(newDrawList);
    _discardPile.setList(newDiscardList);
    _cardCount.value = _drawPile.size();
  }

  void setDeck(_StateModifier _, LootDeckModel model) {
    _setDeck(model);
  }

  void returnLootCard(_StateModifier _, bool top) {
    var card = _discardPile.pop();
    card.owner = "";
    if (top) {
      _drawPile.push(card);
    } else {
      _drawPile.insert(0, card);
    }
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

  void _setDeck(LootDeckModel model) {
    List<LootCard> cards = [];

    if (_hasCard1419) {
      _addOtherType(_kSpecialCard1419, cards, "special 1419");
    }
    if (_hasCard1418) {
      _addOtherType(_kSpecialCard1418, cards, "special 1418");
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
      _addOtherType(_kTreasureCardId, cards, "treasure");
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
    for (int i = 0; i < _kMaterialOneCount; i++) {
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
    for (int i = 0; i < _kMaterialTwoCount; i++) {
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
    for (int i = 0; i < _kMaterialTwoCount; i++) {
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
    for (int i = 0; i < _kHerbPoolCount; i++) {
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

    for (int i = 0; i < _kCoin1Count; i++) {
      _addOtherType(id, _coinPool, "coin 1");
      id++;
    }
    for (int i = 0; i < _kCoin2Count; i++) {
      _addOtherType(id, _coinPool, "coin 2");
      id++;
    }
    _addOtherType(id, _coinPool, "coin 3");
    id++;
    _addOtherType(id, _coinPool, "coin 3");
    id++;

    _initMaterialPool(id, _lumberPool, "lumber");
    id += _kMaterialPoolSize;
    _initMaterialPool(id, _hidePool, "hide");
    id += _kMaterialPoolSize;
    _initMaterialPool(id, _metalPool, "metal");
    id += _kMaterialPoolSize;
    _initHerbPool(id, _arrowvinePool, "arrowvine");
    id += _kHerbPoolSize;
    _initHerbPool(id, _axenutPool, "axenut");
    id += _kHerbPoolSize;
    _initHerbPool(id, _corpsecapPool, "corpsecap");
    id += _kHerbPoolSize;
    _initHerbPool(id, _flamefruitPool, "flamefruit");
    id += _kHerbPoolSize;
    _initHerbPool(id, _snowthistlePool, "snowthistle");
    id += _kHerbPoolSize;
    _initHerbPool(id, _rockrootPool, "rockroot");
  }

  void addSpecial1418(_StateModifier _) {
    if (!_hasCard1418) {
      _hasCard1418 = true;
      _drawPile.add(LootCard(
          id: _kSpecialCard1418,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1418"));
      //add directly to current deck and shuffle. save state separately
      _shuffle();
    }
  }

  void addSpecial1419(_StateModifier _) {
    if (!_hasCard1419) {
      _hasCard1419 = true;
      _drawPile.add(LootCard(
          id: _kSpecialCard1419,
          lootType: LootType.other,
          baseValue: LootBaseValue.one,
          enhanced: 0,
          gfx: "special 1419"));
      _shuffle();
    }
  }

  void removeSpecial1418(_StateModifier _) {
    _hasCard1418 = false;
    _drawPile.removeWhere((element) => element.id == _kSpecialCard1418);
    _discardPile.removeWhere((element) => element.id == _kSpecialCard1418);
    _cardCount.value = _drawPile.size();
  }

  void removeSpecial1419(_StateModifier _) {
    _hasCard1419 = false;
    _drawPile.removeWhere((element) => element.id == _kSpecialCard1419);
    _discardPile.removeWhere((element) => element.id == _kSpecialCard1419);
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
        _drawPile.add(pool.first);
        _addedCards[0] = _addedCards.first + 1;
      }
    }
    if (identifier == "lumber") {
      var pool = _getAvailableCards(_lumberPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[1]++;
      }
    }
    if (identifier == "metal") {
      var pool = _getAvailableCards(_metalPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[2]++;
      }
    }
    if (identifier == "arrowvine") {
      var pool = _getAvailableCards(_arrowvinePool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[3]++;
      }
    }
    if (identifier == "axenut") {
      var pool = _getAvailableCards(_axenutPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[4]++;
      }
    }
    if (identifier == "corpsecap") {
      var pool = _getAvailableCards(_corpsecapPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[5]++;
      }
    }
    if (identifier == "flamefruit") {
      var pool = _getAvailableCards(_flamefruitPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[6]++;
      }
    }
    if (identifier == "rockroot") {
      var pool = _getAvailableCards(_rockrootPool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[7]++;
      }
    }
    if (identifier == "snowthistle") {
      var pool = _getAvailableCards(_snowthistlePool);
      if (pool.isNotEmpty) {
        _drawPile.add(pool.first);
        _addedCards[8]++;
      }
    }
    _shuffle();
  }

  void addEnhancement(_StateModifier _, int id, int value,
      {GameState? gameState, GameData? gameData}) {
    _enhancements[id.toString()] = value;
    //reset loot deck
    _initPools();
    final gs = gameState ?? getIt<GameState>();
    final gd = gameData ?? getIt<GameData>();
    String scenario = gs.scenario.value;
    LootDeckModel? lootDeckModel = gd.modelData.value[gs.currentCampaign.value]
        ?.scenarios[scenario]?.lootDeck;
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

  void draw(_StateModifier _, {GameState? gameState}) {
    //put top of draw pile on discard pile
    LootCard card = _drawPile.pop();

    //mark owner
    final gs = gameState ?? getIt<GameState>();
    for (var item in gs.currentList) {
      if (item.turnState.value == TurnsState.current && item is Character) {
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

enum LootType { materiel, other }

enum LootBaseValue { one, oneIf4twoIfNot, oneIf3or4twoIfNot }
