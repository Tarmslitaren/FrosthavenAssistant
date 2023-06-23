import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class EnfeeblingHexCommand extends Command {
  bool allies;
  EnfeeblingHexCommand(this.allies);

  @override
  void execute() {
    if (allies) {
      getIt<GameState>().modifierDeckAllies.addMinusOne();
    } else {
      getIt<GameState>().modifierDeck.addMinusOne();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Add minus one";
  }
}
