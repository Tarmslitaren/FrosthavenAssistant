import 'package:frosthaven_assistant/Resource/game_methods.dart';

import '../../services/service_locator.dart';
import '../state/game_state.dart';

class AMDCassandraSpecialCommand extends Command {
  String deckId;
  bool on;
  AMDCassandraSpecialCommand(this.deckId, this.on);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    ModifierDeck deck = GameMethods.getModifierDeck(deckId, gameState);
    deck.setCassandraSpecial(stateAccess, on);
  }

  @override
  String describe() {
    if (on) {
      return "Leave revealed cards on top of $deckId deck";
    }
    return "Cassandra Special turned off for $deckId deck";
  }
}
