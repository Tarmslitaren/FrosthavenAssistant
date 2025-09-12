import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AddFactionCardCommand extends Command {
  final String characterId;
  final String cardId;
  final bool add;
  AddFactionCardCommand(this.characterId, this.cardId, this.add);

  @override
  void execute() {
    ModifierDeck? deck =
        GameMethods.getModifierDeck(characterId, getIt<GameState>());
    if (add) {
      deck.addCard(stateAccess, cardId, CardType.add);
    } else {
      deck.removeCard(stateAccess, cardId);
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    return add
        ? "$characterId add faction card"
        : "$characterId remove faction card";
  }
}
