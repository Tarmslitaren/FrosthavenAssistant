import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDImbue1Command extends Command {
  AMDImbue1Command();

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    deck.setImbue1(stateAccess);
  }

  @override
  String describe() {
    return "Imbue Monster Deck";
  }
}
