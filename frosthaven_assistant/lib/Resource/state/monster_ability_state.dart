part of game_state;

class MonsterAbilityState {
  final String name;
  final CardStack<MonsterAbilityCardModel> drawPile =
      CardStack<MonsterAbilityCardModel>();
  final CardStack<MonsterAbilityCardModel> discardPile =
      CardStack<MonsterAbilityCardModel>();

  int get lastRoundDrawn => _lastRoundDrawn;
  int _lastRoundDrawn = 0;

  MonsterAbilityState(this.name) {
    GameState gameState = getIt<GameState>();

    List<MonsterAbilityDeckModel> monsters = [];
    for (String key in gameState.modelData.value.keys) {
      monsters.addAll(gameState.modelData.value[key]!.monsterAbilities);
    }
    for (MonsterAbilityDeckModel model in monsters) {
      if (name == model.name) {
        drawPile.init(model.cards);
        shuffle();
        break;
      }
    }

    _lastRoundDrawn = 0;
  }

  void shuffle() {
    while (discardPile.isNotEmpty) {
      drawPile.push(discardPile.pop());
    }
    drawPile.shuffle();
  }

  void draw() {
    //put top of draw pile on discard pile
    discardPile.push(drawPile.pop());
    _lastRoundDrawn = getIt<GameState>().round.value;
  }

  @override
  String toString() {
    return '{'
        '"name": "$name", '
        '"drawPile": ${drawPile.toString()}, '
        '"discardPile": ${discardPile.toString()}, '
        '"lastRoundDrawn": $lastRoundDrawn '
        '}';
  }
}
