import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveAMDCardCommand extends Command {
  final int index;
  final String name;
  final GameState _gameState;

  RemoveAMDCardCommand(this.index, this.name, {required GameState gameState})
      : _gameState = gameState;
  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.removeCardFromDiscard(stateAccess, index);
  }

  @override
  String describe() {
    return "Remove amd card";
  }
}
