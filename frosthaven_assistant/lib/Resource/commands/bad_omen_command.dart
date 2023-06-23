import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class BadOmenCommand extends Command {
  late final bool allies;
  BadOmenCommand(this.allies);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    if (allies) {
      gameState.modifierDeckAllies.badOmen.value += 6;
    } else {
      gameState.modifierDeck.badOmen.value += 6;
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Bad Omen";
  }
}
