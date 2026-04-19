import '../state/game_state.dart';

class ReorderListCommand extends Command {
  final int newIndex;
  final int oldIndex;
  final GameState _gameState;

  ReorderListCommand(this.newIndex, this.oldIndex,
      {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    RoundMethods.reorderMainList(stateAccess, newIndex, oldIndex);
  }

  @override
  void onUndo() {
    _gameState.updateList.notify();
  }

  @override
  String describe() {
    return "Reorder List";
  }
}
