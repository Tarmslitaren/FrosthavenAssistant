import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../state/game_state.dart';
import 'command_l10n.dart';

class AMDCassandraSpecialCommand extends Command {
  String deckId;
  bool on;
  final GameState _gameState;

  AMDCassandraSpecialCommand(this.deckId, this.on, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    ModifierDeck deck = GameMethods.getModifierDeck(deckId, _gameState);
    deck.setCassandraSpecial(stateAccess, on);
  }

  @override
  String describe() {
    if (on) {
      return commandL10n.cmdCassandraLeaveRevealed(deckId);
    }
    return commandL10n.cmdCassandraSpecialOff(deckId);
  }
}
