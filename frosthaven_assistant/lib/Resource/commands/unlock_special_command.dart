import '../state/game_state.dart';

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
      MutableGameMethods.clearUnlockedClass(stateAccess, _id);
    } else {
      MutableGameMethods.unlockClass(stateAccess, _id);
    }
  }

  @override
  void undo();

  @override
  String describe() {
    if (_unlock) {
      return "Unlock $_id";
    }
    return "clear unlocked: $_id";
  }
}
