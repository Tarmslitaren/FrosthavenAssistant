import '../Model/MonsterAbility.dart';
import '../services/service_locator.dart';
import 'card_stack.dart';
import 'game_state.dart';

class MonsterAbilityState{
  //final MonsterAbilityDeckModel deck;
  MonsterAbilityState(this.name){
    GameState gameState = getIt<GameState>();
    List<MonsterAbilityDeckModel> monsters = [];
    for (String key in gameState.modelData.value.keys){
      monsters.addAll(
          gameState.modelData.value[key]!.monsterAbilities
      );
    }
    for (MonsterAbilityDeckModel model in monsters) {
      if(name == model.name) {
        drawPile.init(model.cards);
        shuffle();
        break;
      }
    }
  }
  final String name;
  final CardStack<MonsterAbilityCardModel> drawPile = CardStack<MonsterAbilityCardModel>();
  final CardStack<MonsterAbilityCardModel> discardPile = CardStack<MonsterAbilityCardModel>();
  void shuffle(){
    while(discardPile.isNotEmpty) {
      drawPile.push(discardPile.pop());
    }
    drawPile.shuffle();
  }
  void draw(){
    //put top of draw pile on discard pile
    discardPile.push(drawPile.pop());
  }

  @override
  String toString() {
    return '{'
        '"name": "$name", '
        '"drawPile": ${drawPile.toString()}, '
        '"discardPile": ${discardPile.toString()} '
        '}';
  }
}
