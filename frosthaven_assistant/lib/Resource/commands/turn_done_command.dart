import '../game_event.dart';
import '../state/game_state.dart';
import 'command_l10n.dart';

class TurnDoneCommand extends Command {
  int index = 0;
  final String id;
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
  }

  @override
  void execute() {
    RoundMethods.setTurnDone(stateAccess, index);
    _gameState.updateList.notify();
  }

  @override
  GameEvent get event => TurnDoneEvent(id);

  @override
  String describe() {
    return commandL10n.cmdTurnDone(id);
  }
}
