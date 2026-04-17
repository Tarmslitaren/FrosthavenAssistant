import '../state/game_state.dart';

class BadOmenCommand extends Command {
  static const int _kBadOmenIncrement = 6;

  late final bool allies;
  final GameState _gameState;

  BadOmenCommand(this.allies, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (allies) {
      _gameState.modifierDeckAllies.setBadOmen(
          stateAccess, _gameState.modifierDeckAllies.badOmen.value + _kBadOmenIncrement);
    } else {
      _gameState.modifierDeck
          .setBadOmen(stateAccess, _gameState.modifierDeck.badOmen.value + _kBadOmenIncrement);
    }
  }

  @override
  String describe() {
    return "Bad Omen";
  }
}
