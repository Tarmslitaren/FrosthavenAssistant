import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDHailCommand extends Command {
  final bool add;
  AMDHailCommand(this.add);

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    final hail = GameMethods.getCharacterByName("Hail");
    hail?.flipPerk(stateAccess, 17);
    if (add) {
      deck.addHailSpecial(stateAccess);
    } else {
      deck.removeHailSpecial(stateAccess);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (add) {
      return "Add Hail special";
    }
    return "Remove Hail special";
  }
}
