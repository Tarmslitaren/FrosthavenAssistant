import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ShuffleAMDCardCommand extends Command {
  final bool allyDeck;
  ShuffleAMDCardCommand(this.allyDeck);

  @override
  void execute() {
    ModifierDeck deck = allyDeck
        ? getIt<GameState>().modifierDeckAllies
        : getIt<GameState>().modifierDeck;

    deck.shuffleUnDrawn(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Extra AMD deck shuffle";
  }
}
