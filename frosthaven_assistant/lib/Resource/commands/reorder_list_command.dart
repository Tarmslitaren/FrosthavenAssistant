
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_state.dart';

class ReorderListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  ReorderListCommand(this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameState gameState = getIt<GameState>();
    gameState.currentList.insert(newIndex,
        gameState.currentList.removeAt(oldIndex));
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String toString() {
    return "Reorder List";
  }
}