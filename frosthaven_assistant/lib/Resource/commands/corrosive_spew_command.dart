import '../game_methods.dart';
import '../state/game_state.dart';

class CorrosiveSpewCommand extends Command {
  final GameState _gameState;

  CorrosiveSpewCommand({required GameState gameState}) : _gameState = gameState;

  @override
  void execute() {
    GameMethods.getModifierDeck("Ruinmaw", _gameState)
        .setCorrosiveSpew(stateAccess);
  }

  @override
  String describe() {
    return "Corrosive Spew";
  }
}
