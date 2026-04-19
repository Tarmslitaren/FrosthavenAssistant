import '../state/game_state.dart';

class AMDRemoveMinus2Command extends Command {
  bool allies;
  bool remove = false;
  final GameState _gameState;

  AMDRemoveMinus2Command(this.allies, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = _gameState.modifierDeck;
    if (allies) {
      deck = _gameState.modifierDeckAllies;
    }
    remove = deck.hasMinus2();
    if (remove) {
      deck.removeMinusTwo(stateAccess);
    } else {
      deck.addMinusTwo(stateAccess);
    }
  }

  @override
  String describe() {
    return remove ? "Remove minus two" : "Add back minus two";
  }
}
