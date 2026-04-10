import '../game_methods.dart';
import '../state/game_state.dart';

class AddFactionCardCommand extends Command {
  final String characterId;
  final String cardId;
  final bool add;
  final GameState _gameState;

  AddFactionCardCommand(this.characterId, this.cardId, this.add,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck? deck = GameMethods.getModifierDeck(characterId, _gameState);
    if (add) {
      deck.addCard(stateAccess, cardId, CardType.add);
    } else {
      deck.removeCard(stateAccess, cardId);
    }
  }

  @override
  String describe() {
    return add
        ? "$characterId add faction card"
        : "$characterId remove faction card";
  }
}
