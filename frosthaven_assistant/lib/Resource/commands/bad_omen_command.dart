import '../state/game_state.dart';

class BadOmenCommand extends Command {
  late final bool allies;
  final GameState _gameState;

  BadOmenCommand(this.allies, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (allies) {
      _gameState.modifierDeckAllies.setBadOmen(
          stateAccess, _gameState.modifierDeckAllies.badOmen.value + 6);
    } else {
      _gameState.modifierDeck
          .setBadOmen(stateAccess, _gameState.modifierDeck.badOmen.value + 6);
    }
  }

  @override
  String describe() {
    return "Bad Omen";
  }
}
