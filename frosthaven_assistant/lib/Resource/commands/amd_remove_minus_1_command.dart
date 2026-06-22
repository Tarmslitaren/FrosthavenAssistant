import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class AMDRemoveMinus1Command extends Command {
  String name;
  final GameState _gameState;

  AMDRemoveMinus1Command(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.removeMinusOne(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdRemoveMinusOne;
  }
}
