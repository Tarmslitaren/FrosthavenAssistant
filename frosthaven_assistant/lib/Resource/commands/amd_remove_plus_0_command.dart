import '../../services/service_locator.dart';
import '../game_methods.dart';
import '../state/game_state.dart';

class AmdRemovePlus0Command extends Command {
  final String name;
  final bool remove;
  AmdRemovePlus0Command(this.name, this.remove);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    if (remove) {
      deck.moveCardToRemovedPile(stateAccess, "plus0");
    } else {
      deck.restoreCardFromRemovedPile(stateAccess, "plus0", CardType.add);
    }
  }

  @override
  String describe() {
    return remove ? "Remove plus zero" : "Add back plus zero";
  }
}
