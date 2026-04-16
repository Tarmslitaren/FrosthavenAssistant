import '../game_methods.dart';
import '../state/game_state.dart';

class AmdRemovePlus0Command extends Command {
  final String name;
  final bool remove;
  final GameState _gameState;

  AmdRemovePlus0Command(this.name, this.remove, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    if (remove) {
      deck.moveCardToRemovedPile(stateAccess, "plus0");
    } else {
      deck.restoreCardFromRemovedPile(stateAccess, "plus0", CardType.add);
    }
  }

  @override
  String describe() {
    return remove ? "Remove plus zero" : "Add back plus zero";
  }
}
