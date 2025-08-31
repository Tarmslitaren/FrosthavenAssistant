import '../../services/service_locator.dart';
import '../state/game_state.dart';

class RemoveCSPartyCardCommand extends Command {
  final String characterId;
  RemoveCSPartyCardCommand(this.characterId);

  @override
  void execute() {
    ModifierDeck? deck =
        GameMethods.getModifierDeck(characterId, getIt<GameState>());
    deck.removeCSPartyCard(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "$characterId remove party card";
  }
}
