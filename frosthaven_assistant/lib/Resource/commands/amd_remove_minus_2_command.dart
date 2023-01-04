import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class AMDRemoveMinus2Command extends Command {
  bool allies;
  AMDRemoveMinus2Command(this.allies);

  @override
  void execute() {
    if (allies) {
      getIt<GameState>().modifierDeckAllies.removeMinusTwo();
    } else {
      getIt<GameState>().modifierDeck.removeMinusTwo();
    }
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    return "Remove minus two";
  }
}