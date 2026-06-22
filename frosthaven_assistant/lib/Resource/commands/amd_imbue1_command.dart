import '../state/game_state.dart';
import 'command_l10n.dart';

class AMDImbue1Command extends Command {
  final GameState _gameState;

  AMDImbue1Command({required GameState gameState}) : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = _gameState.modifierDeck;
    deck.setImbue1(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdImbueMonsterDeck;
  }
}
