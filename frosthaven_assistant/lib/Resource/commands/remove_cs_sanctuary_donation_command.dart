import '../../services/service_locator.dart';
import '../state/game_state.dart';

class RemoveCSSanctuaryDonationCommand extends Command {
  final String characterId;
  RemoveCSSanctuaryDonationCommand(this.characterId);

  @override
  void execute() {
    ModifierDeck? deck =
        GameMethods.getModifierDeck(characterId, getIt<GameState>());
    deck.removeCSSanctuary(stateAccess);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "remove $characterId's donation";
  }
}
