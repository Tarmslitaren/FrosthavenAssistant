import '../state/game_state.dart';

class SetAutoLevelAdjustCommand extends Command {
  SetAutoLevelAdjustCommand(this.on, {required GameState gameState})
      : _gameState = gameState;

  bool on;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.setAutoScenarioLevel(stateAccess, on);
    MutableGameMethods.applyDifficulty(stateAccess);
  }

  @override
  String describe() {
    if (on) {
      return "turn automatic level updated on";
    } else {
      return "turn automatic level updated off";
    }
  }
}
