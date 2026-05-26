import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveAMDCardCommand extends Command {
  final int index;
  final String name;
  final GameState _gameState;
  final bool fromDrawPile;

  RemoveAMDCardCommand({
    required this.index,
    required this.name,
    required GameState gameState,
    this.fromDrawPile = false,
  }) : _gameState = gameState;
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    if (fromDrawPile) {
      deck.removeCardFromDrawPile(stateAccess, index);
    } else {
      deck.removeCardFromDiscard(stateAccess, index);
    }
  }

  @override
  String describe() {
    return "Remove amd card";
  }
}
