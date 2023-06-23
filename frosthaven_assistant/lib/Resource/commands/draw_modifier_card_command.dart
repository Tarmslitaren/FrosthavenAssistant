import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class DrawModifierCardCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String name;

  DrawModifierCardCommand(this.name);

  @override
  void execute() {
    if (name == "allies") {
      _gameState.modifierDeckAllies.draw();
    } else {
      _gameState.modifierDeck.draw();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (name == "allies") {
      return "Draw allies modifier card";
    }
    return "Draw monster modifier card";
  }
}
