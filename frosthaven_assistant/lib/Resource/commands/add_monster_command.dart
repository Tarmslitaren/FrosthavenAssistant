import '../state/game_state.dart';

class AddMonsterCommand extends Command {
  final GameState _gameState;
  final String _name;
  final int? _level;
  final bool _isAlly;
  Monster? monster;

  AddMonsterCommand(this._name, this._level, this._isAlly,
      {required GameState gameState})
      : _gameState = gameState {
    monster =
        MonsterMethods.createMonster(stateAccess, _name, _level, _isAlly);
  }

  @override
  void execute() {
    final m = monster;
    if (m == null) return;
    RoundMethods.addToMainList(stateAccess, null, m);
  }

  @override
  void onUndo() {
    _gameState.updateList.notify();
  }

  @override
  String describe() {
    return "Add ${monster?.type.display ?? ''}";
  }
}
