import '../state/game_state.dart';

class ReorderListCommand extends Command {
  late final int newIndex;
  late final int oldIndex;
  final GameState _gameState;

  ReorderListCommand(this.newIndex, this.oldIndex, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    RoundMethods.reorderMainList(stateAccess, newIndex, oldIndex);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Reorder List";
  }
}
