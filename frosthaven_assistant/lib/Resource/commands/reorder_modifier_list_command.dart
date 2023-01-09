
import 'package:frosthaven_assistant/Resource/state/modifier_deck_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../state/game_state.dart';

class ReorderModifierListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  ReorderModifierListCommand(this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    List<ModifierCard> list = List.from(gameState.modifierDeck.drawPile.getList());
    var item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    gameState.modifierDeck.drawPile.setList(list);
  }


  @override
  void undo() {
  }

  @override
  String describe() {
    return "Reorder Modifier Cards";
  }
}