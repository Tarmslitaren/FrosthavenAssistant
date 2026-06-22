import '../game_methods.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class ShuffleAMDCardCommand extends Command {
  final String name;
  final GameState _gameState;

  ShuffleAMDCardCommand(this.name, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    final deck = GameMethods.getModifierDeck(name, _gameState);
    deck.shuffleUnDrawn(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdExtraAmdShuffle;
  }
}
