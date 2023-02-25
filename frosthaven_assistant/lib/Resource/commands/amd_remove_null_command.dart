import 'package:frosthaven_assistant/Resource/state/modifier_deck_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class AMDRemoveNullCommand extends Command {
  bool allies;
  late bool remove;
  AMDRemoveNullCommand(this.allies);

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    if (allies) {
      deck = getIt<GameState>().modifierDeckAllies;
    }
    remove = deck.hasNull();
    if (remove) {
      deck.removeNull();
    } else {
      deck.addNull();
    }
  }

  @override
  void undo() {
  }

  @override
  String describe() {
    if (remove){
      return "Remove null";
    } else {
      return "Add back null";
    }
  }
}