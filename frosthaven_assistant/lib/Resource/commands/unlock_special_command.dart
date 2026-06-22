import '../state/game_state.dart';
import 'command_l10n.dart';

class UnlockSpecialCommand extends Command {
  final GameState _gameState;
  final String _id;
  bool _unlock = true;

  UnlockSpecialCommand(this._id, {required GameState gameState})
      : _gameState = gameState;

  @override
  void execute() {
    if (_gameState.unlockedClasses.contains(_id)) {
      _unlock = false;
      ScenarioMethods.clearUnlockedClass(stateAccess, _id);
    } else {
      ScenarioMethods.unlockClass(stateAccess, _id);
    }
  }

  @override
  void onUndo();

  @override
  String describe() {
    if (_unlock) {
      return commandL10n.cmdUnlock(_id);
    }
    return commandL10n.cmdLock(_id);
  }
}
