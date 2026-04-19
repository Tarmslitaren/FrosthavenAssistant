import '../state/game_state.dart';

class RemoveMonsterCommand extends Command {
  final GameState _gameState;
  final List<Monster> names;

  RemoveMonsterCommand(this.names, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    MonsterMethods.removeMonsters(stateAccess, names);
  }

  @override
  void onUndo() {
    _gameState.updateList.notify();
  }

  @override
  String describe() {
    if (names.length > 1) {
      return "Remove all monsters";
    }
    return "Remove ${names.first.type.display}";
  }
}
