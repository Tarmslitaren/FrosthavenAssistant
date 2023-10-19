import 'package:frosthaven_assistant/Resource/state/modifier_deck_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class AMDRemoveMinus2Command extends Command {
  bool allies;
  late bool remove;
  AMDRemoveMinus2Command(this.allies);

  @override
  void execute() {
    ModifierDeck deck = getIt<GameState>().modifierDeck;
    if (allies) {
      deck = getIt<GameState>().modifierDeckAllies;
    }
    remove = deck.hasMinus2();
    if (remove) {
      deck.removeMinusTwo();
    } else {
      deck.addMinusTwo();
    }
  }

  @override
  void undo() {}

  @override
  String describe() {
    if (remove) {
      return "Remove minus two";
    } else {
      return "Add back minus two";
    }
  }
}
