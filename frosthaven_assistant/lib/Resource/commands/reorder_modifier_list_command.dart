
import 'package:frosthaven_assistant/Resource/modifier_deck_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class ReorderModifierListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  ReorderModifierListCommand(this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    List<ModifierCard> list = List.from(gameState.modifierDeck.drawPile.getList());
    list.insert(newIndex, list.removeAt(oldIndex));
    gameState.modifierDeck.drawPile.setList(list);
  }


  @override
  void undo() {
  }

  @override
  String toString() {
    return "Reorder modifier";
  }
}