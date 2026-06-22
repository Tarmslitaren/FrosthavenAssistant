import '../state/game_state.dart';
import 'command_l10n.dart';

class SetDifficultyCommand extends Command {
  SetDifficultyCommand(this.difficulty, {required GameState gameState})
      : _gameState = gameState;

  int difficulty;
  final GameState _gameState;

  @override
  void execute() {
    _gameState.setDifficulty(stateAccess, difficulty);
    ScenarioMethods.applyDifficulty(stateAccess);
  }

  @override
  String describe() {
    return commandL10n.cmdSetDifficulty(difficulty.toString());
  }
}
