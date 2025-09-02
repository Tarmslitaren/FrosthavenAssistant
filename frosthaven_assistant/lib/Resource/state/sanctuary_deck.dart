part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class SanctuaryDeck {
  late final CardStack<ModifierCard> _multPile = CardStack<ModifierCard>();
  late final CardStack<ModifierCard> _flipPile = CardStack<ModifierCard>();

  SanctuaryDeck() {
    //build deck
    _initDeck();
  }

  SanctuaryDeck.fromJson(Map<String, dynamic> modifierDeckData) {
    _initDeck();

    List<ModifierCard> newMultList = [];
    List<ModifierCard> newFlipList = [];
    for (var item in modifierDeckData["multPile"] as List) {
      String gfx = item["gfx"];
      newMultList.add(ModifierCard(CardType.remove, gfx));
    }
    for (var item in modifierDeckData["flipPile"] as List) {
      String gfx = item["gfx"];
      newFlipList.add(ModifierCard(CardType.remove, gfx));
    }
    _multPile.setList(newMultList);
    _flipPile.setList(newFlipList);
  }

  ModifierCard drawMult(_StateModifier _) {
    //put top of draw pile on discard pile
    _multPile.shuffle();
    return _multPile.pop();
  }

  ModifierCard drawFlip(_StateModifier _) {
    //put top of draw pile on discard pile
    _flipPile.shuffle();
    return _flipPile.pop();
  }

  void returnCard(String gfx) {
    if (gfx.contains("flip")) {
      _flipPile.add(ModifierCard(CardType.remove, gfx));
      _flipPile.shuffle();
    } else {
      _multPile.add(ModifierCard(CardType.remove, gfx));
      _multPile.shuffle();
    }
  }

  @override
  String toString() {
    return '{'
        '"multPile": ${_multPile.toString()}, '
        '"flipPile": ${_flipPile.toString()} '
        '}';
  }

  void _initDeck() {
    _multPile.clear();
    _flipPile.clear();
    List<ModifierCard> flipCards = [];
    List<ModifierCard> multCards = [];
    final prefix = "sanctuary/";
    for (int i = 1; i < 5; i++) {
      //2 of each of 4 different cards
      flipCards.add(ModifierCard(CardType.remove, "${prefix}flip-$i"));
      flipCards.add(ModifierCard(CardType.remove, "${prefix}flip-$i"));
      multCards.add(ModifierCard(CardType.remove, "${prefix}x2-$i"));
      multCards.add(ModifierCard(CardType.remove, "${prefix}x2-$i"));
    }
    _flipPile.setList(flipCards);
    _multPile.setList(multCards);
    _flipPile.shuffle();
    _multPile.shuffle();
  }
}
