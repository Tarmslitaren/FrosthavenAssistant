
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class BadOmenCommand extends Command {
  BadOmenCommand();

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    gameState.modifierDeck.badOmen.value += 6;
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Bad Omen";
  }
}