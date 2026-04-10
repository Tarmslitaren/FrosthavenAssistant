import '../state/game_state.dart';

class TurnDoneCommand extends Command {
  late int index;
  late String id;
  final GameState _gameState;

  TurnDoneCommand(this.id, {required GameState gameState})
      : _gameState = gameState {
    index = 0;
    for (int i = 0; i < _gameState.currentList.length; i++) {
      if (id == _gameState.currentList[i].id) {
        index = i;
        break;
      }
    }
    _gameState.updateList.value++;
  }

  @override
  void execute() {
    MutableGameMethods.setTurnDone(stateAccess, index);
  }

  @override
  void undo() {
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    return "$id's turn done";
  }
}
