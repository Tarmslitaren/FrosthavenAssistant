import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class RemoveCSSanctuaryDonationCommand extends Command {
  final String characterId;
  final GameState _gameState;

  RemoveCSSanctuaryDonationCommand(this.characterId,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck? deck = GameMethods.getModifierDeck(characterId, _gameState);
    deck.removeCSSanctuary(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdRemoveSanctuaryDonation(characterId);
  }
}
