import '../state/game_state.dart';

class SetInitCommand extends Command {
  final GameState _gameState;
  final String _characterId;
  final int _init;

  SetInitCommand(this._characterId, this._init, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    //add new character on top of list
    for (var item in _gameState.currentList) {
      if (item.id == _characterId && item is Character) {
        item.characterState.setInitiative(stateAccess, _init);
      }
    }
  }

  @override
  void onUndo() {
    _gameState.updateList.notify();
  }

  @override
  String describe() {
    return "Set initiative of $_characterId";
  }
}
