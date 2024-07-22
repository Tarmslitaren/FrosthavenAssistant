part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api
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

class ModifierDeck {
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

  void _curseListener() {
    _handleCurseBless(CardType.curse, _curses, "curse");
  }

  void _blessListener() {
    _handleCurseBless(CardType.bless, _blesses, "bless");
  }

  void _enfeebleListener() {
    _handleCurseBless(CardType.enfeeble, _enfeebles, "enfeeble");
  }

  void initDeck(_StateModifier _, String name) {
    _initDeck(name);
  }

  void _initDeck(String name) {
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
    _needsShuffle = false;
    name = name;
  }

  final String name;

  bool get needsShuffle => _needsShuffle;
  bool _needsShuffle = false;

  //TODO: better safety for these getters
  CardStack<ModifierCard> get drawPile => _drawPile;
  CardStack<ModifierCard> get discardPile => _discardPile;

  final CardStack<ModifierCard> _drawPile = CardStack<ModifierCard>();
  final CardStack<ModifierCard> _discardPile = CardStack<ModifierCard>();

  ValueListenable<int> get curses => _curses;
  final _curses = ValueNotifier<int>(0);
  ValueListenable<int> get blesses => _blesses;
  final _blesses = ValueNotifier<int>(0);
  ValueListenable<int> get enfeebles => _enfeebles;
  final _enfeebles = ValueNotifier<int>(0);
  ValueListenable<int> get cardCount => _cardCount;
  final _cardCount = ValueNotifier<int>(
      0); //TODO: everything is a hammer - use maybe change notifier instead?

  ValueListenable<int> get badOmen => _badOmen;
  final _badOmen = ValueNotifier<int>(0);
  ValueListenable<int> get addedMinusOnes => _addedMinusOnes;
  final _addedMinusOnes = ValueNotifier<int>(0);

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
    var card = _drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "minus1$suffix");
    if (card != null) {
      _drawPile.remove(card);
      _drawPile.shuffle();
      _cardCount.value--;
    }
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
    var card = _drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "nullAttack$suffix");
    if (card != null) {
      _drawPile.remove(card);
      _drawPile.shuffle();
      _cardCount.value--;
    }
  }

  void addNull(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _drawPile
        .add(ModifierCard(CardType.multiply, "nullAttack$suffix"));
    _shuffle();
  }

  void removeMinusTwo(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _shuffle();
    var card = _drawPile
        .getList()
        .lastWhereOrNull((element) => element.gfx == "minus2$suffix");
    if (card != null) {
      _drawPile.remove(card);
      _drawPile.shuffle();
      _cardCount.value--;
    }
  }

  void addMinusTwo(_StateModifier _) {
    String suffix = "";
    if (name.isNotEmpty) {
      suffix = "-$name";
    }
    _drawPile.add(ModifierCard(CardType.add, "minus2$suffix"));
    _shuffle();
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
          if (_drawPile.getList().length < 6) {
            position = _drawPile.getList().length;
          }
          _drawPile.insert(
              _drawPile.getList().length - position, ModifierCard(type, gfx));
        } else {
          _drawPile.push(ModifierCard(type, gfx));
        }
      }
    } else {
      int toRemove = count - notifier.value;
      for (int i = 0; i < toRemove; i++) {
        for (int j = _drawPile.getList().length - 1; j >= 0; j--) {
          if (_drawPile.getList()[j].type == type) {
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

  void shuffle(_StateModifier _) {
    _shuffle();
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
        '"badOmen": ${_badOmen.value.toString()}, '
        '"drawPile": ${_drawPile.toString()}, '
        '"discardPile": ${_discardPile.toString()} '
        '}';
  }
}
