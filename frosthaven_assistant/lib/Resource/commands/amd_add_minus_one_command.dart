import '../game_methods.dart';
import '../state/game_state.dart';

class AmdAddMinusOneCommand extends Command {
  String name;
  final GameState _gameState;

  AmdAddMinusOneCommand(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.addMinusOne(stateAccess);
  }

  @override
  String describe() {
    return "Add minus one";
  }
}
