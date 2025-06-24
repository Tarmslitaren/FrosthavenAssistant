import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDImbue2Command extends Command {
  AMDImbue2Command();

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    deck.setImbue2(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Advanced Imbue Monster Deck";
  }
}
