part of 'game_state.dart';
// ignore_for_file: library_private_types_in_public_api

class MonsterAbilityState {
  final String name;

  final CardStack<MonsterAbilityCardModel> drawPile =
      CardStack<MonsterAbilityCardModel>();
  final CardStack<MonsterAbilityCardModel> discardPile =
      CardStack<MonsterAbilityCardModel>();

  int get lastRoundDrawn => _lastRoundDrawn;
  int _lastRoundDrawn = 0;

  MonsterAbilityState(this.name) {
    GameData gameData = getIt<GameData>();

    List<MonsterAbilityDeckModel> monsters = [];
    for (String key in gameData.modelData.value.keys) {
      monsters.addAll(gameData.modelData.value[key]!.monsterAbilities);
    }
    for (MonsterAbilityDeckModel model in monsters) {
      if (name == model.name) {
        drawPile.init(model.cards);
        _shuffle();
        break;
      }
    }

    _lastRoundDrawn = 0;
  }

  void shuffle(_StateModifier _) {
    _shuffle();
  }

  void _shuffle() {
    while (discardPile.isNotEmpty) {
      drawPile.push(discardPile.pop());
    }
    drawPile.shuffle();
  }

  void draw(_StateModifier _) {
    //put top of draw pile on discard pile
    discardPile.push(drawPile.pop());
    _lastRoundDrawn = getIt<GameState>().totalRounds.value;
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
