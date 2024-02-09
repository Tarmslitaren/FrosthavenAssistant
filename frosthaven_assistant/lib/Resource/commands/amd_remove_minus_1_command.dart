import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDRemoveMinus1Command extends Command {
  bool allies;
  AMDRemoveMinus1Command(this.allies);

  @override
  void execute() {
    if (allies) {
      getIt<GameState>().modifierDeckAllies.removeMinusOne(stateAccess);
    } else {
      getIt<GameState>().modifierDeck.removeMinusOne(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove minus one";
  }
}
