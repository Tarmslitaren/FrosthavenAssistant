part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class MonsterAbilityState {
  final String name;

  final CardStack<MonsterAbilityCardModel> _drawPile =
      CardStack<MonsterAbilityCardModel>();
  final CardStack<MonsterAbilityCardModel> _discardPile =
      CardStack<MonsterAbilityCardModel>();

  int get lastRoundDrawn => _lastRoundDrawn;
  int _lastRoundDrawn = 0;

  BuiltList<MonsterAbilityCardModel> get drawPileContents =>
      BuiltList.of(_drawPile.getList());
  BuiltList<MonsterAbilityCardModel> get discardPileContents =>
      BuiltList.of(_discardPile.getList());
  bool get drawPileIsEmpty => _drawPile.isEmpty;
  bool get drawPileIsNotEmpty => _drawPile.isNotEmpty;
  bool get discardPileIsEmpty => _discardPile.isEmpty;
  bool get discardPileIsNotEmpty => _discardPile.isNotEmpty;
  MonsterAbilityCardModel get drawPileTop => _drawPile.peek;
  MonsterAbilityCardModel get discardPileTop => _discardPile.peek;
  int get drawPileSize => _drawPile.size();
  int get discardPileSize => _discardPile.size();

  MonsterAbilityState(this.name) {
    GameData gameData = getIt<GameData>();

    List<MonsterAbilityDeckModel> monsters = [];
    for (String key in gameData.modelData.value.keys) {
      monsters.addAll(gameData.modelData.value[key]!.monsterAbilities);
    }
    for (MonsterAbilityDeckModel model in monsters) {
      if (name == model.name) {
        _drawPile.init(model.cards);
        _shuffle();
        break;
      }
    }

    _lastRoundDrawn = 0;
  }

  void shuffle(_StateModifier _) {
    _shuffle();
  }

  void shuffleUnDrawn(_StateModifier _) {
    _drawPile.shuffle();
  }

  void removeFromDrawPile(_StateModifier _, MonsterAbilityCardModel card) {
    _drawPile.remove(card);
  }

  void removeFromDiscardPile(_StateModifier _, MonsterAbilityCardModel card) {
    _discardPile.remove(card);
  }

  void reorderDrawPile(_StateModifier _, int oldIndex, int newIndex) {
    final list = _drawPile.getList();
    list.insert(newIndex, list.removeAt(oldIndex));
    _drawPile.setList(list);
  }

  void _shuffle() {
    while (_discardPile.isNotEmpty) {
      _drawPile.push(_discardPile.pop());
    }
    _drawPile.shuffle();
  }

  void draw(_StateModifier _) {
    //put top of draw pile on discard pile
    _discardPile.push(_drawPile.pop());
    _lastRoundDrawn = getIt<GameState>().totalRounds.value;
  }

  @override
  String toString() {
    return '{'
        '"name": "$name", '
        '"drawPile": ${_drawPile.toString()}, '
        '"discardPile": ${_discardPile.toString()}, '
        '"lastRoundDrawn": $lastRoundDrawn '
        '}';
  }
}
