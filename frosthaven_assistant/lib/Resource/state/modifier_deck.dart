part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api

class ModifierDeck {
  static const int _kImbuementLevel1 = 1;
  static const int _kImbuementLevel2 = 2;
  static const int _kPlusMinus1Count = 5;
  static const int _kPlus0Count = 6;
  static const int _kCursePosition = 5;

  final String name;
  final CardStack<ModifierCard> _drawPile = CardStack<ModifierCard>();
  final CardStack<ModifierCard> _discardPile = CardStack<ModifierCard>();
  final CardStack<ModifierCard> _removedPile = CardStack<ModifierCard>();
  final Map<String, ValueNotifier<int>> _removables = {
    "curse": ValueNotifier<int>(0),
    "bless": ValueNotifier<int>(0),
    "in-enfeeble": ValueNotifier<int>(0),
    "vi-enfeeble": ValueNotifier<int>(0),
    "vi-gr-enfeeble": ValueNotifier<int>(0),
    "li-enfeeble": ValueNotifier<int>(0),
    "in-empower": ValueNotifier<int>(0),
    "rm-empower": ValueNotifier<int>(0),
    "vi-empower": ValueNotifier<int>(0),
    "vi-gr-empower": ValueNotifier<int>(0),
  };

  final _cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?
  final _badOmen = ValueNotifier<int>(0);
  final _corrosiveSpew = ValueNotifier<bool>(false);
  final _addedMinusOnes = ValueNotifier<int>(0);
  final _imbuement = ValueNotifier<int>(0);

  final _revealedCount = ValueNotifier<int>(0);
  final _cassandraSpecial = ValueNotifier<bool>(false);

  bool _needsShuffle = false;
  bool get needsShuffle => _needsShuffle;

  BuiltList<ModifierCard> get drawPileContents =>
      BuiltList.of(_drawPile.getList());
  BuiltList<ModifierCard> get discardPileContents =>
      BuiltList.of(_discardPile.getList());
  BuiltList<ModifierCard> get removedPileContents =>
      BuiltList.of(_removedPile.getList());
  bool get drawPileIsEmpty => _drawPile.isEmpty;
  bool get drawPileIsNotEmpty => _drawPile.isNotEmpty;
  bool get discardPileIsEmpty => _discardPile.isEmpty;
  bool get discardPileIsNotEmpty => _discardPile.isNotEmpty;
  int get drawPileSize => _drawPile.size();
  int get discardPileSize => _discardPile.size();
  int get removedPileSize => _removedPile.size();
  ModifierCard get discardPileTop => _discardPile.peek;
  ModifierCard get drawPileTop => _drawPile.peek;

  ValueListenable<int> get cardCount => _cardCount;
  ValueListenable<int> get badOmen => _badOmen;
  ValueListenable<bool> get corrosiveSpew => _corrosiveSpew;
  ValueListenable<int> get addedMinusOnes => _addedMinusOnes;
  ValueListenable<int> get imbuement => _imbuement;
  ValueListenable<int> get revealedCount => _revealedCount;
  ValueListenable<bool> get cassandraSpecial => _cassandraSpecial;

  ModifierDeck(this.name) {
    //build deck
    _initDeck();
    _initListeners();
  }

  ModifierDeck.fromJson(this.name, Map<String, dynamic> modifierDeckData) {
    _initDeck();
    _initListeners();
    updateFromJson(modifierDeckData);
  }

  /// Resets this deck to the default 20-card state, firing all notifiers.
  void resetToDefault() {
    _initDeck();
    _cassandraSpecial.value = false;
  }

  /// Updates this deck in-place from [modifierDeckData], firing all relevant
  /// [ValueNotifier] listeners so subscribed widgets rebuild automatically.
  void updateFromJson(Map<String, dynamic> modifierDeckData) {
    // Reset removable counts first (fires _handleRemovableCards on the current
    // pile, but the piles are fully replaced below anyway).
    for (var key in _removables.keys) {
      _removables[key]?.value = 0;
    }
    _needsShuffle = false;

    for (var item in modifierDeckData["drawPile"] as List) {
      String gfx = item["gfx"];
      if (gfx == "curse" ||
          gfx.contains("empower") ||
          gfx.contains("enfeeble") ||
          gfx == "bless") {
        addRemovableValue(_StateModifier(), gfx, 1);
      }
    }
    for (var item in modifierDeckData["discardPile"] as List) {
      String gfx = item["gfx"];
      if (_isMultiplyType(gfx)) {
        _needsShuffle = true;
      }
    }

    _drawPile.clear();
    _discardPile.clear();
    _removedPile.clear();
    _drawPile.setList(_getCardsFromJson(modifierDeckData, "drawPile"));
    _discardPile.setList(_getCardsFromJson(modifierDeckData, "discardPile"));
    if (modifierDeckData.containsKey('removedPile')) {
      _removedPile.setList(_getCardsFromJson(modifierDeckData, "removedPile"));
    }
    _cardCount.value = _drawPile.size();

    _imbuement.value = modifierDeckData.containsKey("imbuement")
        ? modifierDeckData['imbuement'] as int
        : 0;
    _badOmen.value = modifierDeckData.containsKey('badOmen')
        ? modifierDeckData["badOmen"] as int
        : 0;
    _corrosiveSpew.value = modifierDeckData.containsKey('corrosiveSpew')
        ? modifierDeckData["corrosiveSpew"] as bool
        : false;
    _revealedCount.value = modifierDeckData.containsKey('revealed')
        ? modifierDeckData["revealed"] as int
        : 0;
    _cassandraSpecial.value = modifierDeckData.containsKey('cassandra')
        ? modifierDeckData["cassandra"] as bool
        : false;
    _addedMinusOnes.value = modifierDeckData.containsKey('addedMinusOnes')
        ? modifierDeckData["addedMinusOnes"] as int
        : 0;
  }

  void setRemovableValue(_StateModifier _, String id, int value) {
    _removables[id]?.value = value;
  }

  void addRemovableValue(_StateModifier _, String id, int value) {
    _removables[id]?.value += value;
  }

  ValueListenable<int> getRemovable(String id) {
    _removables[id] ??= ValueNotifier<int>(0);
    return _removables[id] ?? ValueNotifier<int>(0);
  }

  void moveCardToRemovedPile(_StateModifier s, String gfx) {
    if (hasCard(gfx)) {
      removeCard(s, gfx);
      _removedPile.add(ModifierCard(CardType.add, gfx));
    }
  }

  void restoreCardFromRemovedPile(_StateModifier s, String gfx, CardType type) {
    addCard(s, gfx, type);
    _removedPile.removeFirstWhere((card) => card.gfx == gfx);
  }

  void setBadOmen(_StateModifier _, int value) {
    _badOmen.value = value;
  }

  void setCorrosiveSpew(_StateModifier _) {
    _corrosiveSpew.value = true;
  }

  void addCSSanctuary(_StateModifier s, {GameState? gameState}) {
    //adds one of each
    final gs = gameState ?? getIt<GameState>();
    _drawPile.add(gs._sanctuaryDeck.drawFlip(s));
    _drawPile.add(gs._sanctuaryDeck.drawMult(s));
    _drawPile.shuffle();
    _cardCount.value = _drawPile.size();
  }

  void removeCSSanctuary(_StateModifier _, {GameState? gameState}) {
    var list = _drawPile.getList();
    final gs = gameState ?? getIt<GameState>();
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].gfx.startsWith("sanctuary")) {
        gs._sanctuaryDeck.returnCard(list[i].gfx);
        _drawPile.removeAt(i);
      }
    }
    list = _discardPile.getList();
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].gfx.startsWith("sanctuary")) {
        gs._sanctuaryDeck.returnCard(list[i].gfx);
        _discardPile.removeAt(i);
      }
    }
    _cardCount.value = _drawPile.size();
  }

  bool hasCSSanctuary() {
    if (_drawPile.getList().firstWhereOrNull((test) {
              return test.gfx.startsWith("sanctuary");
            }) !=
            null ||
        _discardPile.getList().firstWhereOrNull((test) {
              return test.gfx.startsWith("sanctuary");
            }) !=
            null) {
      return true;
    }
    return false;
  }

  void addCSPartyCard(_StateModifier s, int type) {
    addCard(s, "party/$type", CardType.remove);
  }

  void removeCSPartyCard(_StateModifier _) {
    _drawPile.removeWhere((test) {
      return test.gfx.startsWith("party/");
    });
    _discardPile.removeWhere((test) {
      return test.gfx.startsWith("party/");
    });
    _cardCount.value = _drawPile.size();
  }

  bool hasPartyCard() {
    if (_drawPile.getList().firstWhereOrNull((test) {
              return test.gfx.startsWith("party/");
            }) !=
            null ||
        _discardPile.getList().firstWhereOrNull((test) {
              return test.gfx.startsWith("party/");
            }) !=
            null) {
      return true;
    }
    return false;
  }

  void addHailSpecial(_StateModifier s) {
    addCard(s, "special/hail", CardType.add);
  }

  void removeHailSpecial(_StateModifier s) {
    removeCard(s, "special/hail");
  }

  void revealCards(_StateModifier _, int amount) {
    _revealedCount.value = amount;
  }

  void setCassandraSpecial(_StateModifier _, bool on) {
    _cassandraSpecial.value = on;
  }

  bool hasHail() {
    if (_discardPile
            .getList()
            .firstWhereOrNull((item) => item.gfx == "special/hail") !=
        null) {
      return true;
    }
    if (_drawPile
            .getList()
            .firstWhereOrNull((item) => item.gfx == "special/hail") !=
        null) {
      return true;
    }
    return false;
  }

  void addMinusOne(_StateModifier _) {
    _addedMinusOnes.value++;
    _drawPile.add(ModifierCard(CardType.add, "minus1"));
    _drawPile.shuffle();
    _revealedCount.value = 0;
    _cardCount.value++;
    if (_addedMinusOnes.value < 0) {
      //do not add/remove extra minus ones to removed pile
      _removedPile.removeFirstWhere((item) => item.gfx == "minus1");
    }
  }

  void removeMinusOne(_StateModifier _) {
    _shuffle();

    final card = _removeCardFromDrawPile("minus1");
    if (card != null) {
      _addedMinusOnes.value--;
      if (_addedMinusOnes.value < 0) {
        _removedPile.add(card);
      }
    }
  }

  bool hasMinus1() {
    return _drawPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "minus1") !=
            null ||
        _discardPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "minus1") !=
            null;
  }

  bool hasMinus2() {
    return !(_removedPile
            .getList()
            .firstWhereOrNull((element) => element.gfx == "minus2") !=
        null);
  }

  bool hasNull() {
    return _drawPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "nullAttack") !=
            null ||
        _discardPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "nullAttack") !=
            null;
  }

  void removeNull(_StateModifier _) {
    _shuffle();
    final card = _removeCardFromDrawPile("nullAttack");
    if (card != null) {
      _removedPile.add(card);
    }
  }

  void addNull(_StateModifier _) {
    _drawPile.add(ModifierCard(CardType.multiply, "nullAttack"));
    _removedPile.removeFirstWhere((item) => item.gfx == "nullAttack");
    _shuffle();
  }

  bool hasCard(String gfx) {
    final drawPileHas =
        _drawPile.getList().firstWhereOrNull((test) => test.gfx == gfx) != null;
    final discardPileHas =
        _discardPile.getList().firstWhereOrNull((test) => test.gfx == gfx) !=
            null;
    return (drawPileHas || discardPileHas);
  }

  void removeCard(_StateModifier _, String gfx) {
    _shuffle();
    _removeCardFromDrawPile(gfx);
    _shuffle();
  }

  void removeCardFromDiscard(_StateModifier _, int index) {
    var card = _discardPile.removeAt(index);
    _removedPile.add(card);
    if (card.gfx == "minus1") {
      _addedMinusOnes.value--;
    }
  }

  void returnCardToDiscard(_StateModifier _, int index) {
    var card = _removedPile.removeAt(index);
    _discardPile.add(card);
    if (card.gfx == "minus1") {
      _addedMinusOnes.value++;
    }
  }

  void returnCardToDrawPile(_StateModifier _) {
    var card = _discardPile.pop();
    _drawPile.push(card);
    _cardCount.value = _drawPile.size();
    //todo: how to tell if revealed should change? if it is over 0?
  }

  void addCard(_StateModifier _, String id, CardType type) {
    _drawPile.add(ModifierCard(type, id));
    _shuffle();
  }

  void removeMinusTwo(_StateModifier _) {
    _shuffle();
    final card = _removeCardFromDrawPile("minus2");
    if (card != null) {
      _removedPile.add(card);
    }
  }

  void addMinusTwo(_StateModifier _) {
    _drawPile.add(ModifierCard(CardType.add, "minus2"));
    _removedPile.removeFirstWhere((item) => item.gfx == "minus2");
    _shuffle();
  }

  void setImbue1(_StateModifier _) {
    assert(name.isEmpty); //only basic deck for this feature

    _shuffle();
    _removeCardFromDrawPile("minus1");
    _removeCardFromDrawPile("minus1");
    _removeCardFromDrawPile("minus1");
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus2muddle"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus0poison"));
    _shuffle();
    _imbuement.value = _kImbuementLevel1;
  }

  void setImbue2(_StateModifier m) {
    assert(name.isEmpty); //only basic deck for this feature

    if (_imbuement.value == 0) {
      setImbue1(m);
    }

    _shuffle();
    _removeCardFromDrawPile("minus2");
    _removeCardFromDrawPile("plus0");
    _removeCardFromDrawPile("plus0");

    _drawPile.add(ModifierCard(CardType.add, "imbue2-plus3"));
    _drawPile.add(ModifierCard(CardType.add, "imbue2-plus1heal1"));
    _drawPile.add(ModifierCard(CardType.add, "imbue2-plus1heal1"));
    _drawPile.add(ModifierCard(CardType.add, "imbue2-plus1curse"));
    _drawPile.add(ModifierCard(CardType.add, "imbue2-plus0wound"));
    _shuffle();
    _imbuement.value = _kImbuementLevel2;
  }

  void resetImbue(_StateModifier _) {
    assert(name.isEmpty); //only basic deck for this feature

    if (_imbuement.value != 0) {
      _shuffle();
      _drawPile.removeWhere((element) => element.gfx.startsWith("imbue"));

      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      if (_imbuement.value == _kImbuementLevel2) {
        if (hasMinus2()) {
          //if minus2 has not been separately removed
          _drawPile.add(ModifierCard(CardType.add, "minus2"));
        }
        _drawPile.add(ModifierCard(CardType.add, "plus0"));
        _drawPile.add(ModifierCard(CardType.add, "plus0"));
      }
      _imbuement.value = 0;
      _shuffle();
    }
  }

  void shuffle(_StateModifier _) {
    if (_cassandraSpecial.value) {
      //dont shuffle the revealed cards
      _shuffleOnlyBelowRevealed();
    } else {
      _shuffle();
    }
  }

  void shuffleUnDrawn(_StateModifier _) {
    _drawPile.shuffle();
    _revealedCount.value = 0;
  }

  void draw(_StateModifier _) {
    if (_revealedCount.value > 0) {
      _revealedCount.value--;
    }
    //shuffle deck, for the case the deck ends during play
    if (_drawPile.isEmpty) {
      _shuffle();
    }
    //put top of draw pile on discard pile
    ModifierCard card = _drawPile.pop();
    if (card.type == CardType.multiply) {
      _needsShuffle = true;
    }

    if (_removables[card.gfx] != null) {
      addRemovableValue(_StateModifier(), card.gfx, -1);
    }
    _discardPile.push(card);
    _cardCount.value = _drawPile.size();
  }

  void reorderCards(_StateModifier s, int newIndex, int oldIndex) {
    List<ModifierCard> list = List.of(_drawPile.getList());
    var item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _drawPile.setList(list);

    //if rearranging between revealed and unrevealed then un-reveal everything below the unknown moved card.
    final revertOldIndex = _drawPile.size() - oldIndex;
    final revertNewIndex = _drawPile.size() - newIndex;
    if (revertOldIndex <= revealedCount.value &&
        revertNewIndex > revealedCount.value) {
      //moving one revealed card to unrevealed area - hide one
      revealCards(s, revealedCount.value - 1);
    }
    if (revertNewIndex <= revealedCount.value &&
        revertOldIndex > revealedCount.value) {
      //hide new index card and those below
      revealCards(s, revertNewIndex - 1);
    }
  }

  @override
  String toString() {
    return '{'
        '"addedMinusOnes": ${_addedMinusOnes.value.toString()}, '
        '"imbuement": ${_imbuement.value.toString()}, '
        '"badOmen": ${_badOmen.value.toString()}, '
        '"corrosiveSpew": ${_corrosiveSpew.value.toString()}, '
        '"revealed": ${_revealedCount.value.toString()}, '
        '"cassandra": ${_cassandraSpecial.value.toString()}, '
        '"drawPile": ${_drawPile.toString()}, '
        '"removedPile": ${_removedPile.toString()}, '
        '"discardPile": ${_discardPile.toString()} '
        '}';
  }

  void _initListeners() {
    for (var item in _removables.keys) {
      _removables[item]?.removeListener(() {
        final r = _removables[item]; if (r != null) _handleRemovableCards(r, item);
      });
      _removables[item]?.addListener(() {
        final r = _removables[item]; if (r != null) _handleRemovableCards(r, item);
      });
    }
  }

  List<ModifierCard> _getCardsFromJson(
      Map<String, dynamic> modifierDeckData, String deckId) {
    List<ModifierCard> newList = [];
    for (var item in modifierDeckData[deckId] as List) {
      String gfx = item["gfx"];
      gfx = gfx.replaceAll("-allies", "");
      if (gfx == "curse") {
        newList.add(ModifierCard(CardType.remove, gfx));
      } else if (gfx.contains("enfeeble")) {
        if (gfx == "enfeeble") {
          //if updating from old version
          gfx = "in-enfeeble";
        }
        newList.add(ModifierCard(CardType.remove, gfx));
      } else if (gfx.contains("empower")) {
        newList.add(ModifierCard(CardType.remove, gfx));
      } else if (gfx == "bless") {
        newList.add(ModifierCard(CardType.remove, gfx));
      } else if (_isMultiplyType(gfx)) {
        newList.add(ModifierCard(CardType.multiply, gfx));
      } else {
        newList.add(ModifierCard(CardType.add, gfx));
      }
    }
    return newList;
  }

  void _initDeck() {
    List<ModifierCard> cards = [];
    cards.add(ModifierCard(CardType.add, "minus2"));
    cards.add(ModifierCard(CardType.add, "plus2"));
    cards.add(ModifierCard(CardType.multiply, "doubleAttack"));
    cards.add(ModifierCard(CardType.multiply, "nullAttack"));
    for (int i = 0; i < _kPlusMinus1Count; i++) {
      cards.add(ModifierCard(CardType.add, "minus1"));
      cards.add(ModifierCard(CardType.add, "plus1"));
    }
    for (int i = 0; i < _kPlus0Count; i++) {
      cards.add(ModifierCard(CardType.add, "plus0"));
    }
    _drawPile.setList(cards);
    _discardPile.setList([]);
    _removedPile.setList([]);
    _shuffle();
    _cardCount.value = _drawPile.size();
    _badOmen.value = 0;
    _corrosiveSpew.value = false;
    _addedMinusOnes.value = 0;
    _imbuement.value = 0;
    _needsShuffle = false;
    for (var item in _removables.keys) {
      _removables[item]?.value = 0;
    }
  }

  ModifierCard? _removeCardFromDrawPile(String gfx) {
    var card =
        _drawPile.getList().lastWhereOrNull((element) => element.gfx == gfx);
    if (card != null) {
      _drawPile.remove(card);
      _drawPile.shuffle();
      _cardCount.value--;
    }
    return card;
  }

  void _handleRemovableCards(ValueNotifier<int> notifier, String gfx) {
    //count and add or remove, then shuffle
    int count = 0;
    bool shuffle = true;
    for (var item in _drawPile.getList()) {
      if (item.gfx == gfx) {
        count++;
      }
    }
    if (count == notifier.value) {
      shuffle = false;
    } else if (count < notifier.value) {
      for (int i = count; i < notifier.value; i++) {
        if (gfx == "rm-empower" && corrosiveSpew.value) {
          shuffle = false;
          //put on top
          //_drawPile.insert(0, ModifierCard(CardType.remove, gfx));
          _drawPile.push(ModifierCard(CardType.remove, gfx));
        } else if (gfx == "curse" && badOmen.value > 0) {
          _badOmen.value--;
          shuffle = false;
          //put in sixth or as far down as it goes.
          int position = _kCursePosition;
          final size = _drawPile.getList().length;
          if (size < _kPlus0Count) {
            position = size;
          }
          _drawPile.insert(size - position, ModifierCard(CardType.remove, gfx));
        } else {
          _drawPile.push(ModifierCard(CardType.remove, gfx));
        }
      }
    } else {
      int toRemove = count - notifier.value;
      final list = _drawPile.getList();
      for (int i = 0; i < toRemove; i++) {
        for (int j = list.length - 1; j >= 0; j--) {
          if (list[j].gfx == gfx) {
            _drawPile.removeAt(j);
            break;
          }
        }
      }
    }
    if (shuffle) {
      _drawPile.shuffle();
    }
    _cardCount.value = _drawPile.size();
  }

  void _shuffle() {
    while (_discardPile.isNotEmpty) {
      ModifierCard card = _discardPile.pop();
      //remove curse and bless
      if (card.type != CardType.remove) {
        _drawPile.push(card);
      }
    }
    _drawPile.shuffle();

    _needsShuffle = false;
    _cardCount.value = _drawPile.size();
    _revealedCount.value = 0;
  }

  void _shuffleOnlyBelowRevealed() {
    final revealCount = _revealedCount.value;
    List<ModifierCard> revealed = [];
    for (int i = 0; i < _revealedCount.value; i++) {
      revealed.add(_drawPile.pop());
    }
    _shuffle();
    _revealedCount.value = revealCount;
    for (int i = 0; i < _revealedCount.value; i++) {
      _drawPile.add(revealed[i]);
    }
  }

  bool _isMultiplyType(String gfx) {
    if (gfx.contains("nullAttack") || gfx.contains("doubleAttack")) {
      return true;
    }
    if (gfx == "P4" && name == "Nightshroud") {
      if (GameMethods.getCharacterByName("Nightshroud")
              ?.characterClass
              .edition ==
          "Gloomhaven 2nd Edition") {
        return true;
      }
    }
    return false;
  }
}

enum CardType { add, multiply, remove }

class ModifierCard {
  final CardType type;
  final String gfx;

  ModifierCard(this.type, this.gfx);

  @override
  String toString() {
    return '{'
        '"gfx": "$gfx" '
        '}';
  }
}
