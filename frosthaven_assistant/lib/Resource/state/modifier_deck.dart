part of 'game_state.dart';

// ignore_for_file: library_private_types_in_public_api

class ModifierDeck {
  final String name;
  final CardStack<ModifierCard> _drawPile = CardStack<ModifierCard>();
  final CardStack<ModifierCard> _discardPile = CardStack<ModifierCard>();
  final _curses = ValueNotifier<int>(0);
  final _blesses = ValueNotifier<int>(0);
  final _enfeebles = ValueNotifier<int>(0);
  final _cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?
  final _badOmen = ValueNotifier<int>(0);
  final _addedMinusOnes = ValueNotifier<int>(0);
  final _imbuement = ValueNotifier<int>(0);

  bool _needsShuffle = false;
  bool get needsShuffle => _needsShuffle;

  //TODO: better safety for these getters
  CardStack<ModifierCard> get drawPile => _drawPile;
  CardStack<ModifierCard> get discardPile => _discardPile;

  ValueListenable<int> get curses => _curses;
  ValueListenable<int> get blesses => _blesses;
  ValueListenable<int> get enfeebles => _enfeebles;
  ValueListenable<int> get cardCount => _cardCount;
  ValueListenable<int> get badOmen => _badOmen;
  ValueListenable<int> get addedMinusOnes => _addedMinusOnes;
  ValueListenable<int> get imbuement => _imbuement;

  ModifierDeck(this.name) {
    //build deck
    _initDeck(name);
    _curses.removeListener(_curseListener);
    _blesses.removeListener(_blessListener);
    _enfeebles.removeListener(_enfeebleListener);

    _curses.addListener(_curseListener);
    _blesses.addListener(_blessListener);
    _enfeebles.addListener(_enfeebleListener);
  }

  ModifierDeck.fromJson(this.name, Map<String, dynamic> modifierDeckData) {
    ModifierDeck(name);

    List<ModifierCard> newDrawList = [];
    List drawPile = modifierDeckData["drawPile"] as List;
    for (var item in drawPile) {
      String gfx = item["gfx"];
      if (gfx == "curse") {
        newDrawList.add(ModifierCard(CardType.curse, gfx));
      } else if (gfx == "enfeeble") {
        newDrawList.add(ModifierCard(CardType.enfeeble, gfx));
      } else if (gfx == "bless") {
        newDrawList.add(ModifierCard(CardType.bless, gfx));
      } else if (gfx.contains("nullAttack") || gfx.contains("doubleAttack")) {
        newDrawList.add(ModifierCard(CardType.multiply, gfx));
      } else {
        newDrawList.add(ModifierCard(CardType.add, gfx));
      }
    }
    List<ModifierCard> newDiscardList = [];
    for (var item in modifierDeckData["discardPile"] as List) {
      String gfx = item["gfx"];
      if (gfx == "curse") {
        newDiscardList.add(ModifierCard(CardType.curse, gfx));
      } else if (gfx == "enfeeble") {
        newDiscardList.add(ModifierCard(CardType.enfeeble, gfx));
      } else if (gfx == "bless") {
        newDiscardList.add(ModifierCard(CardType.bless, gfx));
      } else if (gfx.contains("nullAttack") || gfx.contains("doubleAttack")) {
        newDiscardList.add(ModifierCard(CardType.multiply, gfx));
        _needsShuffle = true;
      } else {
        newDiscardList.add(ModifierCard(CardType.add, gfx));
      }
    }
    _drawPile.clear();
    _discardPile.clear();
    _drawPile.setList(newDrawList);
    _discardPile.setList(newDiscardList);
    _cardCount.value = _drawPile.size();

    if (modifierDeckData.containsKey("curses")) {
      int curses = modifierDeckData['curses'];
      _curses.value = curses;
    }
    if (modifierDeckData.containsKey("enfeebles")) {
      int enfeebles = modifierDeckData['enfeebles'];
      _enfeebles.value = enfeebles;
    }
    if (modifierDeckData.containsKey("imbuement")) {
      int imbuement = modifierDeckData['imbuement'];
      _imbuement.value = imbuement;
    }
    if (modifierDeckData.containsKey("blesses")) {
      int blesses = modifierDeckData['blesses'];
      _blesses.value = blesses;
    }

    if (modifierDeckData.containsKey('badOmen')) {
      _badOmen.value = modifierDeckData["badOmen"] as int;
    }
    if (modifierDeckData.containsKey('addedMinusOnes')) {
      _addedMinusOnes.value = modifierDeckData["addedMinusOnes"] as int;
    }
  }

  void setCurse(_StateModifier _, int value) {
    _curses.value = value;
  }

  void setEnfeeble(_StateModifier _, int value) {
    _enfeebles.value = value;
  }

  void setBless(_StateModifier _, int value) {
    _blesses.value = value;
  }

  void setBadOmen(_StateModifier _, int value) {
    _badOmen.value = value;
  }

  void addMinusOne(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _addedMinusOnes.value++;
    _drawPile.add(ModifierCard(CardType.add, "minus1$suffix"));
    _drawPile.shuffle();
    _cardCount.value++;
  }

  void removeMinusOne(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _shuffle();
    _addedMinusOnes.value--;

    _removeCardFromDrawPile("minus1$suffix");
  }

  bool hasMinus1() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return _drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus1$suffix") !=
            null ||
        _discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus1$suffix") !=
            null;
  }

  bool hasMinus2() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return _drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus2$suffix") !=
            null ||
        _discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "minus2$suffix") !=
            null;
  }

  bool hasNull() {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    return _drawPile.getList().firstWhereOrNull(
                (element) => element.gfx == "nullAttack$suffix") !=
            null ||
        _discardPile.getList().firstWhereOrNull(
                (element) => element.gfx == "nullAttack$suffix") !=
            null;
  }

  void removeNull(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _shuffle();
    _removeCardFromDrawPile("nullAttack$suffix");
  }

  void addNull(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _drawPile.add(ModifierCard(CardType.multiply, "nullAttack$suffix"));
    _shuffle();
  }

  void removeMinusTwo(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _shuffle();
    _removeCardFromDrawPile("minus2$suffix");
  }

  void addMinusTwo(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _drawPile.add(ModifierCard(CardType.add, "minus2$suffix"));
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
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus2-muddle"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus0-poison"));
    _shuffle();
    _imbuement.value = 1;
    _cardCount.value = _drawPile.size();
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

    _drawPile.add(ModifierCard(CardType.add, "imbue-plus3"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1-heal"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1-heal"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus1-curse"));
    _drawPile.add(ModifierCard(CardType.add, "imbue-plus0-wound"));
    _shuffle();
    _imbuement.value = 2;
    _cardCount.value = _drawPile.size();
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
      _cardCount.value = _drawPile.size();
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

    if (card.type == CardType.curse) {
      _curses.value--;
    }
    if (card.type == CardType.bless) {
      _blesses.value--;
    }
    if (card.type == CardType.enfeeble) {
      _enfeebles.value--;
    }

    _discardPile.push(card);
    _cardCount.value = _drawPile.size();
  }

  @override
  String toString() {
    return '{'
        '"blesses": ${_blesses.value}, '
        '"curses": ${_curses.value}, '
        '"enfeebles": ${_enfeebles.value}, '
        '"addedMinusOnes": ${_addedMinusOnes.value.toString()}, '
        '"imbuement": ${_imbuement.value.toString()}, '
        '"badOmen": ${_badOmen.value.toString()}, '
        '"drawPile": ${_drawPile.toString()}, '
        '"discardPile": ${_discardPile.toString()} '
        '}';
  }

  void _curseListener() {
    _handleCurseBless(CardType.curse, _curses, "curse");
  }

  void _blessListener() {
    _handleCurseBless(CardType.bless, _blesses, "bless");
  }

  void _enfeebleListener() {
    _handleCurseBless(CardType.enfeeble, _enfeebles, "enfeeble");
  }

  void _initDeck(final String name) {
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
    _drawPile.setList(cards);
    _discardPile.setList([]);
    _shuffle();
    _cardCount.value = _drawPile.size();
    _curses.value = 0;
    _blesses.value = 0;
    _enfeebles.value = 0;
    _badOmen.value = 0;
    _addedMinusOnes.value = 0;
    _imbuement.value = 0;
    _needsShuffle = false;
  }

  _removeCardFromDrawPile(String gfx) {
    var card =
        _drawPile.getList().lastWhereOrNull((element) => element.gfx == gfx);
    if (card != null) {
      _drawPile.remove(card);
      _drawPile.shuffle();
      _cardCount.value--;
    }
  }

  void _handleCurseBless(
      CardType type, ValueNotifier<int> notifier, String gfx) {
    //count and add or remove, then shuffle
    int count = 0;
    bool shuffle = true;
    for (var item in _drawPile.getList()) {
      if (item.type == type) {
        count++;
      }
    }
    if (count == notifier.value) {
      shuffle = false;
    } else if (count < notifier.value) {
      for (int i = count; i < notifier.value; i++) {
        if (type == CardType.curse && badOmen.value > 0) {
          _badOmen.value--;
          shuffle = false;
          //put in sixth or as far down as it goes.
          int position = 5;
          final size = _drawPile.getList().length;
          if (size < 6) {
            position = size;
          }
          _drawPile.insert(size - position, ModifierCard(type, gfx));
        } else {
          _drawPile.push(ModifierCard(type, gfx));
        }
      }
    } else {
      int toRemove = count - notifier.value;
      final list = _drawPile.getList();
      for (int i = 0; i < toRemove; i++) {
        for (int j = list.length - 1; j >= 0; j--) {
          if (list[j].type == type) {
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
      if (card.type != CardType.bless &&
          card.type != CardType.curse &&
          card.type != CardType.enfeeble) {
        _drawPile.push(card);
      }
    }
    _drawPile.shuffle();

    _needsShuffle = false;
    _cardCount.value = _drawPile.size();
  }
}

enum CardType { add, multiply, curse, bless, enfeeble }

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
