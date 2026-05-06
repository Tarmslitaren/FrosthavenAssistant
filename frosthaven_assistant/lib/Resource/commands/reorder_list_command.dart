import '../state/game_state.dart';

class ReorderListCommand extends Command {
  final int newIndex;
  final int oldIndex;

  ReorderListCommand(
    this.newIndex,
    this.oldIndex, {
    required GameState gameState,
  });

  @override
  void execute() {
    RoundMethods.reorderMainList(stateAccess, newIndex, oldIndex);
  }

  @override
  String describe() {
    return "Reorder List";
  }
}
