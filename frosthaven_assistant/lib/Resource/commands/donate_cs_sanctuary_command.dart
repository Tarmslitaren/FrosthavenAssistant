import '../game_methods.dart';
import '../state/game_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

class DonateCSSanctuaryCommand extends Command {
  final String characterId;
  final GameState _gameState;

  DonateCSSanctuaryCommand(this.characterId, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck? deck = GameMethods.getModifierDeck(characterId, _gameState);
    deck.addCSSanctuary(stateAccess);
  }

  @override
  String describe() {
    return "$characterId donate to sanctuary";
  }
}
