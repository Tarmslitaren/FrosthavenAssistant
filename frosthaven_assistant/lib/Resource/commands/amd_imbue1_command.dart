import '../state/game_state.dart';

class AMDImbue1Command extends Command {
  final GameState _gameState;

  AMDImbue1Command({required GameState gameState}) : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = _gameState.modifierDeck;
    deck.setImbue1(stateAccess);
  }

  @override
  String describe() {
    return "Imbue Monster Deck";
  }
}
