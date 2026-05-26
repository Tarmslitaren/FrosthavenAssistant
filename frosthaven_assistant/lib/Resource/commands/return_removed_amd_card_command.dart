import '../game_methods.dart';
import '../state/game_state.dart';

class ReturnRemovedAMDCardCommand extends Command {
  final int index;
  final String name;
  final bool toDrawPile;
  final GameState _gameState;

  ReturnRemovedAMDCardCommand({
    required this.index,
    required this.name,
    this.toDrawPile = false,
    required GameState gameState,
  }) : _gameState = gameState;
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    if (toDrawPile) {
      deck.returnCardToDrawPileFromRemoved(stateAccess, index);
    } else {
      deck.returnCardToDiscard(stateAccess, index);
    }
  }

  @override
  String describe() {
    return "Return removed amd card";
  }
}
