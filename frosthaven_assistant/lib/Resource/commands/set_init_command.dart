import '../../services/service_locator.dart';
import '../state/game_state.dart';

class SetInitCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final String _characterId;
  final int _init;

  SetInitCommand(this._characterId, this._init);

  @override
  void execute() {
    //add new character on top of list
    for (var item in _gameState.currentList) {
      if (item.id == _characterId) {
        (item as Character).characterState.setInitiative(stateAccess, _init);
      }
    }
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "Set initiative of $_characterId";
  }
}
