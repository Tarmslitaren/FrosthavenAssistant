import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class AMDRemoveMinus1Command extends Command {
  bool allies;
  AMDRemoveMinus1Command(this.allies);

  @override
  void execute() {
    if (allies) {
      getIt<GameState>().modifierDeckAllies.removeMinusOne();
    } else {
      getIt<GameState>().modifierDeck.removeMinusOne();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove minus one";
  }
}
