import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class DrawModifierCardCommand extends Command {
  final String name;
  final GameState _gameState = getIt<GameState>();

  DrawModifierCardCommand(this.name);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    deck.draw(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (name.isNotEmpty) {
      return "Draw $name modifier card";
    }
    return "Draw monster modifier card";
  }
}
