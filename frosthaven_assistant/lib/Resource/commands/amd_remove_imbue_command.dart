import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDRemoveImbueCommand extends Command {
  AMDRemoveImbueCommand();

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    deck.resetImbue(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Remove Imbuement";
  }
}
