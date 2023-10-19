import 'package:frosthaven_assistant/Resource/state/modifier_deck_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class ReorderModifierListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  late final bool allies;
  ReorderModifierListCommand(this.newIndex, this.oldIndex, this.allies);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    ModifierDeck deck = gameState.modifierDeck;
    if (allies) {
      deck = gameState.modifierDeckAllies;
    }
    List<ModifierCard> list = List.from(deck.drawPile.getList());

    var item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    deck.drawPile.setList(list);
  }

  @override
  void undo() {}

  @override
  String describe() {
    return "Reorder Modifier Cards";
  }
}
