part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api

class ModifierDeck {
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

  bool _needsShuffle = false;
  bool get needsShuffle => _needsShuffle;

  //TODO: better safety for these getters
  CardStack<ModifierCard> get drawPile => _drawPile;
  CardStack<ModifierCard> get discardPile => _discardPile;
  CardStack<ModifierCard> get removedPile => _removedPile;

  ValueListenable<int> get cardCount => _cardCount;
  ValueListenable<int> get badOmen => _badOmen;
  ValueListenable<bool> get corrosiveSpew => _corrosiveSpew;
  ValueListenable<int> get addedMinusOnes => _addedMinusOnes;
  ValueListenable<int> get imbuement => _imbuement;

  ModifierDeck(this.name) {
    //build deck
    _initDeck();
    _initListeners();
  }

  ModifierDeck.fromJson(this.name, Map<String, dynamic> modifierDeckData) {
    _initDeck();
    _initListeners();

    for (var item in modifierDeckData["drawPile"] as List) {
      String gfx = item["gfx"];
      if (gfx == "curse" ||
          gfx.contains("empower") ||
          gfx.contains("enfeeble") ||
          gfx == "bless") {
        addRemovableValue(gfx, 1);
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

    if (modifierDeckData.containsKey("imbuement")) {
      int imbuement = modifierDeckData['imbuement'];
      _imbuement.value = imbuement;
    }

    if (modifierDeckData.containsKey('badOmen')) {
      _badOmen.value = modifierDeckData["badOmen"] as int;
    }
    if (modifierDeckData.containsKey('corrosiveSpew')) {
      _corrosiveSpew.value = modifierDeckData["corrosiveSpew"] as bool;
    }
    if (modifierDeckData.containsKey('addedMinusOnes')) {
      _addedMinusOnes.value = modifierDeckData["addedMinusOnes"] as int;
    }
  }

  void setRemovableValue(String id, int value) {
    _removables[id]?.value = value;
  }

  void addRemovableValue(String id, int value) {
    _removables[id]?.value += value;
  }

  ValueNotifier<int> getRemovable(String id) {
    if (_removables[id] == null) {
      _removables[id] = ValueNotifier<int>(0);
    }
    return _removables[id]!;
  }

  void setBadOmen(_StateModifier _, int value) {
    _badOmen.value = value;
  }

  void setCorrosiveSpew(_StateModifier _) {
    _corrosiveSpew.value = true;
  }

  void addCSSanctuary(_StateModifier s) {
    //adds one of each
    final GameState gameState = getIt<GameState>();
    _drawPile.add(gameState._sanctuaryDeck.drawFlip(s));
    _drawPile.add(gameState._sanctuaryDeck.drawMult(s));
    _drawPile.shuffle();
    _cardCount.value = _drawPile.size();
  }

  void removeCSSanctuary(_StateModifier _) {
    var list = _drawPile.getList();
    final GameState gameState = getIt<GameState>();
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].gfx.startsWith("sanctuary")) {
        gameState._sanctuaryDeck.returnCard(list[i].gfx);
        _drawPile.removeAt(i);
      }
    }
    list = _discardPile.getList();
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].gfx.startsWith("sanctuary")) {
        gameState._sanctuaryDeck.returnCard(list[i].gfx);
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
    discardPile.removeWhere((test) {
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

  bool hasHail() {
    if (discardPile
            .getList()
            .firstWhereOrNull((item) => item.gfx == "special/hail") !=
        null) {
      return true;
    }
    if (drawPile
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
    return _drawPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "minus2") !=
            null ||
        _discardPile
                .getList()
                .firstWhereOrNull((element) => element.gfx == "minus2") !=
            null;
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
    _imbuement.value = 1;
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
    _imbuement.value = 2;
  }

  void resetImbue(_StateModifier _) {
    assert(name.isEmpty); //only basic deck for this feature

    if (_imbuement.value != 0) {
      _shuffle();
      _drawPile.removeWhere((element) => element.gfx.startsWith("imbue"));

      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      _drawPile.add(ModifierCard(CardType.add, "minus1"));
      if (_imbuement.value == 2) {
        _drawPile.add(ModifierCard(CardType.add, "minus2"));
        _drawPile.add(ModifierCard(CardType.add, "plus0"));
        _drawPile.add(ModifierCard(CardType.add, "plus0"));
      }
      _imbuement.value = 0;
      _shuffle();
    }
  }

  void shuffle(_StateModifier _) {
    _shuffle();
  }

  void shuffleUnDrawn(_StateModifier _) {
    _drawPile.shuffle();
  }

  void draw(_StateModifier _) {
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
      addRemovableValue(card.gfx, -1);
    }
    _discardPile.push(card);
    _cardCount.value = _drawPile.size();
  }

  @override
  String toString() {
    return '{'
        '"addedMinusOnes": ${_addedMinusOnes.value.toString()}, '
        '"imbuement": ${_imbuement.value.toString()}, '
        '"badOmen": ${_badOmen.value.toString()}, '
        '"corrosiveSpew": ${_corrosiveSpew.value.toString()}, '
        '"drawPile": ${_drawPile.toString()}, '
        '"removedPile": ${_removedPile.toString()}, '
        '"discardPile": ${_discardPile.toString()} '
        '}';
  }

  void _initListeners() {
    for (var item in _removables.keys) {
      _removables[item]?.removeListener(() {
        _handleRemovableCards(_removables[item]!, item);
      });
      _removables[item]?.addListener(() {
        _handleRemovableCards(_removables[item]!, item);
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
    for (int i = 0; i < 5; i++) {
      cards.add(ModifierCard(CardType.add, "minus1"));
      cards.add(ModifierCard(CardType.add, "plus1"));
    }
    for (int i = 0; i < 6; i++) {
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
          int position = 5;
          final size = _drawPile.getList().length;
          if (size < 6) {
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
