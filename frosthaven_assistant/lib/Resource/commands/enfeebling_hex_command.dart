import '../../services/service_locator.dart';
import '../state/game_state.dart';

class EnfeeblingHexCommand extends Command {
  bool allies;
  EnfeeblingHexCommand(this.allies);

  @override
  void execute() {
    if (allies) {
      getIt<GameState>().modifierDeckAllies.addMinusOne(stateAccess);
    } else {
      getIt<GameState>().modifierDeck.addMinusOne(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Add minus one";
  }
}
