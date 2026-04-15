import '../game_event.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class DrawModifierCardCommand extends Command {
  final String name;
  final GameState _gameState;

  DrawModifierCardCommand(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.draw(stateAccess);
  }

  @override
  String describe() {
    if (name.isNotEmpty) {
      return "Draw $name modifier card";
    }
    return "Draw monster modifier card";
  }

  @override
  GameEvent get event => ModifierCardDrawnEvent(name);
}
