import '../../services/service_locator.dart';
import '../state/game_state.dart';

class ReorderListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  ReorderListCommand(this.newIndex, this.oldIndex);

  @override
  void execute() {
    GameMethods.reorderMainList(stateAccess, newIndex, oldIndex);
  }

  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    return "Reorder List";
  }
}
