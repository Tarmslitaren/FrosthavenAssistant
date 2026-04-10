import '../game_methods.dart';
import '../state/game_state.dart';

class AddCSPartyCardCommand extends Command {
  final String characterId;
  final int type;
  final GameState _gameState;

  AddCSPartyCardCommand(this.characterId, this.type,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck? deck = GameMethods.getModifierDeck(characterId, _gameState);
    deck.addCSPartyCard(stateAccess, type);
  }

  @override
  String describe() {
    return "$characterId add party card $type";
  }
}
