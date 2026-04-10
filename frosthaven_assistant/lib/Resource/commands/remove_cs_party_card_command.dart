import '../game_methods.dart';
import '../state/game_state.dart';

class RemoveCSPartyCardCommand extends Command {
  final String characterId;
  final GameState _gameState;

  RemoveCSPartyCardCommand(this.characterId, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck? deck = GameMethods.getModifierDeck(characterId, _gameState);
    deck.removeCSPartyCard(stateAccess);
  }

  @override
  String describe() {
    return "$characterId remove party card";
  }
}
