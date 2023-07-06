
import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDRemoveMinus2Command extends Command {
  bool allies;
  late bool remove;
  AMDRemoveMinus2Command(this.allies);

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    if (allies) {
      deck = getIt<GameState>().modifierDeckAllies;
    }
    remove = deck.hasMinus2();
    if (remove) {
      deck.removeMinusTwo(stateAccess);
    } else {
      deck.addMinusTwo(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (remove) {
      return "Remove minus two";
    } else {
      return "Add back minus two";
    }
  }
}
