import '../state/game_state.dart';

class AMDImbue2Command extends Command {
  final GameState _gameState;

  AMDImbue2Command({required GameState gameState}) : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = _gameState.modifierDeck;
    deck.setImbue2(stateAccess);
  }

  @override
  String describe() {
    return "Advanced Imbue Monster Deck";
  }
}
