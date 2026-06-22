import '../state/game_state.dart';
import 'command_l10n.dart';

class AMDRemoveImbueCommand extends Command {
  final GameState _gameState;

  AMDRemoveImbueCommand({required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = _gameState.modifierDeck;
    deck.resetImbue(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdRemoveImbueMonsterDeck;
  }
}
