import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AmdRemovePlus0Command extends Command {
  final String name;
  final bool remove;
  AmdRemovePlus0Command(this.name, this.remove);

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, getIt<GameState>());
    if (remove) {
      if (deck.hasCard("plus0")) {
        deck.removeCard(stateAccess, "plus0");
        deck.removedPile.add(ModifierCard(CardType.add, "plus0"));
      }
    } else {
      deck.addCard(stateAccess, "plus0", CardType.add);
      deck.removedPile.remove(ModifierCard(CardType.add, "plus0"));
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return remove ? "Remove plus one" : "Add back plus one";
  }
}
